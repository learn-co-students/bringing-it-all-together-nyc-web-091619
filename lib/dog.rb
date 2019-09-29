require 'pry'
class Dog

    # def self.find_or_create_by(name:, album:)
    #     song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
    #     if !song.empty?
    #       song_data = song[0]
    #       song = Song.new(song_data[0], song_data[1], song_data[2])
    #     else
    #       song = self.create(name: name, album: album)
    #     end
    #     song
    # end

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                album TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    # binding.pry

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new(id: row[0], name: row[1], breed: row[2])
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            new_dog = dog[0]
            dog = self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end 

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql, name)[0]
        Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end