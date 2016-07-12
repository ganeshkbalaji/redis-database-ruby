class TuroDatabase

  attr_accessor :database, :transactions, :transaction_count

  def initialize
    self.database = {}
    self.transactions = {}
    self.transaction_count = 0
    self.database_number_equal_to = Hash.new()
    self.transaction_number_equal_to = Hash.new()
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

  def process_input
    #input from stdin / file
    ARGF.each_line { |inputs|
    inputs = inputs.downcase.split(' ')
    command = inputs[0].to_sym unless inputs[0].nil?
    name = inputs[1] ||= nil
    value = inputs[2] ||= nil

    case command
      when :set
        self.set name, value if validate_operation(command, :required => {:name => name, :value => value})
      when :unset
        self.unset(name) if validate_operation(command, :required => {:name => name})
      when :get
        self.display_result(get(name)) if validate_operation(command, :required => {:name => name})
      when :numequalto
        self.display_result(numequalto(name)) if validate_operation(command, :required => {:name => name})
      when :begin
        self.begin
      when :rollback
        in_transaction? ? self.rollback : display_result('No Transaction')
      when :commit
        in_transaction? ? self.commit : display_result('No Transaction')
      when :end
        exit
      else
        self.send(command)
      end
      process_input
    }
  end

  def validate_operation(command, options=nil)
  end
end
