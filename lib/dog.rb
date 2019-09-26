class Dog
    attr_accessor :name, :breed, :id

    def initialize(params)
        @name = params[:name]
        @breed = params[:breed]
        @id = params[:id]
    end

    #INSTANCE METHODS
    def save
        if self.id
            self.update
        else 
            doggo = Dog.new({name: name, breed: breed})
            sql = <<-SQL
                INSERT INTO dogs (name, breed) 
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
        self
    end

    #CLASS METHODS

    def self.find_or_create_by(name:, breed:)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !doggo.empty? #if the dog is already in the db, just make a Dog
            doggo_traits = doggo[0]
            doggo = self.new( name:doggo_traits[1], breed: doggo_traits[2], id:doggo_traits[0])
        else #otherwise make a Dog instance and save to db
            doggo =self.create(name: name, breed: breed)
        end
        doggo
    end

    def self.create(params)
        doggo = self.new(params)
        doggo.save
        doggo
    end

    def self.new_from_db(row)
        parameters = {name: row[1], breed: row[2], id: row[0]}
        student = self.new(parameters)
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        new_from_db(row)
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
        new_from_db(row)
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

end #END DOG