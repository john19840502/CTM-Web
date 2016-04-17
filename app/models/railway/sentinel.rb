class Sentinel < DatabaseRailway
  #####
  # The purpose of this model is to allow asynchronous processes to coordinate themselves.
  # Currently, the model only holds a counter for delayed job coordination.
  #####
  belongs_to :watchable, :polymorphic => true
end
