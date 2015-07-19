class Users::Member < User
  def admin?
    false
  end

  def member?
    true
  end
end
