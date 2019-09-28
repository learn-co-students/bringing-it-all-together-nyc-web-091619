class Dog

    attr_accessor :id
    attr_reader :name, :breed

    def initialize(id:,name:,bread:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end























end #end of Dog