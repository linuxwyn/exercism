class Mute

  attr_reader :submission, :user
  def initialize(submission, user)
    @submission, @user = submission, user
  end

  def save
    if submission.pending?
      submission.muted_by << user.username
      hibernate! if hibernate?
    end
    submission.save
  end

  private

  def hibernate?
    has_nits? && locksmith? && stale?
  end

  def hibernate!
    submission.state = 'hibernating'
    Notify.source(submission, 'hibernating')
  end

  def has_nits?
    submission.nits_by_others_count > 0
  end

  def locksmith?
    user.unlocks?(submission.exercise)
  end

  def stale?
    latest_nit_at <= a_week_ago
  end

  def a_week_ago
    Time.now - (60 * 60 * 24 * 7)
  end

  def latest_nit_at
    submission.nits_by_others.map(&:at).sort.last
  end
end
