class Users::Admin < Users::Member
  def admin?
    true
  end
end
