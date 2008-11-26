class ActiveRecord::Base
  # backported from http://github.com/rails/rails/commit/e328bdaab6c1cf920af3cabc0a27e32798a9fcb6
  # Merges conditions so that the result is a valid +condition+
  # This will allow us to use the merge_conditions feature on pre rails 2.1 apps
  def self.merge_conditions_backport(*conditions)
    segments = []

    conditions.each do |condition|
      unless condition.blank?
        sql = sanitize_sql(condition)
        segments << sql unless sql.blank?
      end
    end

    "(#{segments.join(') AND (')})" unless segments.empty?
  end

end
