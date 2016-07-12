class SimpleDatabase

  attr_accessor :database, :transactions, :count

  def initialize
    self.database = {}
    self.transactions = {}
    @count = 0
  end

  def set(name, value)
  end

  def unset(name)
  end

  def get(name)
  end

  def num_equal_to(value)
  end

  def end
  end

  def begin
  end

  def rollback
  end

  def commit
  end
end
