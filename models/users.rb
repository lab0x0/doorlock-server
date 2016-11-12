module Users

  class Member < ::User
    def admin?
      false
    end

    def member?
      true
    end
  end

  class Admin < User
    def admin?
      true
    end

    def member?
      true
    end
  end
  
  class SuperUser < User
    def admin?
      true
    end

    def member?
      true
    end
  end

end
