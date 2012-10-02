class StatsJob
  @queue = :stats

  def self.perform(user_id)
    user = User.find(user_id)
    user.send_stats_email
  end
end