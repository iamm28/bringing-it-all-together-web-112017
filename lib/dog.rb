class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      new_dog = Dog.new(id: self.id, name: self.name, breed: self.breed)
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def self.create(row)
    new_dog = Dog.new(id:row[:id],name:row[:name],breed:row[:breed])
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "select * from dogs where id = ?"
    record = DB[:conn].execute(sql,id)
    self.new_from_db(record[0])
  end

  def self.find_or_create_by(dog_hash)
    sql = "select * from dogs where name = ? AND breed = ?"
    dog_s = DB[:conn].execute(sql, dog_hash[:name],dog_hash[:breed])
    if dog_s.length < 1
      self.create(dog_hash)
    else
      self.find_by_id(dog_s[0][0])
    end
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_name(name)
    sql = "select * from dogs where name = ?"
    record = DB[:conn].execute(sql,name)
    self.new_from_db(record[0])
  end

end
