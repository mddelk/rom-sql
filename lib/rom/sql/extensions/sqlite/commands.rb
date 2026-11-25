# frozen_string_literal: true

require 'rom/sql/commands/create'

module ROM
  module SQL
    module SQLite
      module Commands
        module Create
          # @api private
          def insert(tuples)
            pks = tuples.map do |tuple|
              if relation.schema[relation.primary_key].unwrap.type.primitive == Integer
                relation.insert(tuple)
              else
                # For non-integer primary keys, SQLite returns `rowid`, so we
                # have to explicitly return the primary key.
                relation.dataset.returning(relation.primary_key).insert(tuple)[0][relation.primary_key]
              end
            end
            relation.dataset.where(relation.primary_key => pks).to_a
          end
        end
      end
    end

    Commands::SQLite = SQLite::Commands

    Gateway.subscribe('configuration.commands.class.before_build') do |event|
      klass = event[:command]

      # TODO: remove this conditional in favor of `adapter: :sql` in subscribe
      #       this is here for backward compatibilty with rom-core 4.x
      if klass.adapter == :sql
        dataset = event[:dataset]
        type = dataset.db.database_type

        if type == :sqlite
          ext =
            if klass < Commands::Create
              SQLite::Commands::Create
            end

          klass.include(ext) if ext
        end
      end
    end
  end
end
