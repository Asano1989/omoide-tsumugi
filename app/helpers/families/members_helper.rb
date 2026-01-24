module Families
  module MembersHelper
    def delete_or_optout(user)
      if user.id == current_user.id
        "脱退する"
      else
        "削除する"
      end
    end
  end
end
