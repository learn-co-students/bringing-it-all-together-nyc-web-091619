
require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name    
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTERGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT into dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
       self.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(name: name, breed: breed, id: id)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map{|row|self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
            And
            breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.new(name: name, breed: breed)
            dog.save
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map{|row|self.new_from_db(row)}.first
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end #end of Dog class

