class PagePolicy < Struct.new(:user, :page)

  def home?
    true
  end

  def user_loggedin?
    user != nil
  end
end
