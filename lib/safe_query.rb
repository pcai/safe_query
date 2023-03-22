module ActiveRecord
  class UnsafeQueryError < StandardError
    # skip ourselves in the backtrace so it ends in the user code that generated the issue
    def backtrace
      return @lines if @lines
      @lines = super
      @lines.shift if @lines.present?
      @lines
    end
  end
  
  class Relation
    module SafeQuery
      def each
        QueryRegistry.reset
        super

        query_to_check = QueryRegistry.queries.first.to_s

        unless query_to_check.blank? || query_to_check.upcase.include?("LIMIT ") || query_to_check.upcase.include?("IN ")
          raise UnsafeQueryError, "Detected a potentially dangerous #each iterator on an unpaginated query. " +
            "Perhaps you need to add pagination, a limit clause, or use the ActiveRecord::Batches methods. \n\n" +
            "To ignore this problem, or if it is a false positive, convert it to an array with ActiveRecord::Relation#to_a before iterating.\n\n" ++
            "Potentially unpaginated query: \n\n  #{query_to_check}"
        end
      end

      ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
        QueryRegistry.queries << payload[:sql]
      end

      module QueryRegistry
        extend self

        def queries
          ActiveSupport::IsolatedExecutionState[:active_record_query_registry] ||= []
        end

        def reset
          queries.clear
        end
      end
    end
  end
end

ActiveRecord::Relation.prepend ActiveRecord::Relation::SafeQuery
