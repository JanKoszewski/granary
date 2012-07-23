class Seed < Neo4j::Rails::Model
  property  :link
  property  :created_at
  property  :updated_at

  has_one(:pledge)
  has_n(:helpers).to(Participant)
  has_n(:reseeds).to(Seed)

  index :link

  def tree
    start = id.to_i
    tree_hash = { start => { :children => {}, :payout_cents => pledge.payout_cents, 
                             :amount_cents => pledge.amount_cents,
                             :link => link} }

    outgoing(:reseeds).outgoing(:helpers).depth(:all).include_start_node.raw.paths.depth_first(:pre).each do |path|
      path_nodes = path.nodes.to_a
      tree_walk = tree_hash[path_nodes.first.id]
     
      path_nodes[1..-1].each do |node|
        unless tree_walk[:children][node.id]
          tree_walk[:children].merge!({ node.id => { :children => {}}})
        end

        if path.end_node == node
          new_hash = {}
          if path.last_relationship
            rel_type = path.last_relationship.rel_type
            new_hash[:type] = rel_type

            if rel_type == :reseeds
              seed = Seed.find(node.id)
              new_hash[:payout_cents] = seed.pledge.payout_cents
              new_hash[:amount_cents] = seed.pledge.amount_cents
              new_hash[:link] = seed.link
            end
          end

          tree_walk[:children][node.id].merge!(new_hash)
        end

        tree_walk = tree_walk[:children][node.id]
      end
    end
    tree_hash
  end

  def self.plant(amount_cents)
    unique_url = generate_link
    seed = Seed.create(:link => unique_url)
    donation = create_donation(amount_cents)
    seed.pledge = donation
    seed.save
    seed
  end

  def self.reseed(link, amount_cents)
    child = plant(amount_cents)
    parent_seed = Seed.find(:link => link)
    parent_seed.outgoing(:reseeds) << child
    parent_seed.save
    parent_seed
  end

  # These likely belong elsewhere.
  def self.generate_link
    Digest::MD5.hexdigest(Time.now.to_s)
    # JQTODO: Add another criteria to save against race conditions.
  end

  def self.create_donation(amount_cents)
    donation = Donation.create(:amount_cents => amount_cents,
                               :payout_cents => 100)
  end
end
