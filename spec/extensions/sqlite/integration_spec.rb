# frozen_string_literal: true

RSpec.describe 'SQLite extension', :sqlite do
  include_context 'database setup'

  setup_tables do
    conn.drop_table?(:people)
  end

  context 'with a non-integer primary key' do
    setup_tables do
      conn.create_table :people do
        column :id, String, primary_key: true, default: 'uuid-goes-here'
        column :name, String
      end
    end

    setup_relations do
      conf.relation(:people) do
        schema(:people, infer: true) do
          attribute :id, Types::String, primary_key: true
        end
      end

      conf.commands(:people) do
        define(:create)
      end
    end

    let(:people_relation) { relations[:people] }
    let(:people) { commands[:people] }

    describe 'insert' do
      let(:person) { { id: 'uuid-goes-here', name: 'John Doe' } }

      it 'inserts the non-integer primary key' do
        expect(people.create.call(name: 'John Doe')).to eq([person])
        expect(people_relation.to_a).to eql([person])
      end
    end
  end

  context 'with an integer primary key' do
    setup_tables do
      conn.create_table :people do
        primary_key :id
        column :name, String
      end
    end

    setup_relations do
      conf.relation(:people) do
        schema(:people, infer: true)
      end

      conf.commands(:people) do
        define(:create)
      end
    end

    let(:people_relation) { relations[:people] }
    let(:people) { commands[:people] }

    describe 'insert' do
      let(:person) { { id: 1, name: 'John Doe' } }

      it 'inserts the integer primary key' do
        expect(people.create.call(name: 'John Doe')).to eq([person])
        expect(people_relation.to_a).to eql([person])
      end
    end
  end
end
