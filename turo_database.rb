class TuroDatabase

  attr_accessor :database, :transactions, :transaction_count, :database_number_equal_to, :transaction_number_equal_to

  def initialize
    self.database = {}
    self.transactions = {}
    self.transaction_count = 0
    self.database_number_equal_to = Hash.new(0)
    self.transaction_number_equal_to = Hash.new(0)
  end

  #set the variable name to the value, neither variable names or value will contain spaces
  def set(name, value)
    update(name, value)
  end

  #unset the variable name, so that the variable is never set
  def unset(name)
    update(name, nil)
  end

  #print out the value of the variable name or null if that variable is not set
  def get(name)
    name_in_transaction?(name) ? get_value_from_deepest_transaction(name) : self.database[name]
  end

  #print out the number of variables that are currently set to value.
  def num_equal_to(value)
    if in_transaction?
      self.transaction_number_equal_to[value] + self.database_number_equal_to[value] ||= 0
    else
      self.database_number_equal_to[value] ||= 0
    end
  end

  # open a new transaction block.
  def begin
    self.transaction_count += 1
  end

  def rollback()
    self.transactions.each do |name, trans|
      last = self.get(name)
      trans.delete_if { |k| k[0] == self.transaction_count }
      self.transactions.delete(name) if trans.empty?
      self.update_num_equal_to(last, self.get(name))
    end
    self.transaction_count -= 1
    self.transactions = {} if self.transaction_count == 0
  end

  def commit
    self.transactions.each do |key, value|
      value.sort_by { |trans| trans[0] }.each do |ordered|
        # "ordered #{ordered}"
        update key, ordered[1], true
      end
    end
    self.transactions = {}
    self.transaction_count = 0
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

  def update(name, value, commit = false)
    current = self.get(name)

    #if in a transaction, create the empty array if value is nil
    self.transactions[name] ||= [] unless self.transaction_count.zero?
    if !in_transaction? || commit
      self.database[name] = value unless self.database[name] == value
    elsif in_transaction?
      transaction_value = [self.transaction_count, value]
      self.transactions[name] << transaction_value unless self.transactions[name].include? transaction_value
    elsif value.nil?
      self.database.delete_if { |val| val == name } #not in transaction / delete from database
    end
    update_num_equal_to(current, value)
  end

  def update_num_equal_to(current, new=nil)
    [[-1, current], [1, new]].each do |counter_operator, value|
      if in_transaction?
        self.transaction_number_equal_to[value] += counter_operator
      else
        self.database_number_equal_to[value] += counter_operator
      end unless value.nil?
    end
  end

  def validate_operation(command, options=nil)
    all_required_present = options[:required].values.all? { |req| !req.nil? }
    unless all_required_present
      puts "INVALID OPERATION. #{command.upcase} requires: (#{options[:required].keys.join(', ')})"
      FALSE
    else
      TRUE
    end
  end

  def display_result(value)
    puts value.nil? ? 'NULL' : value
  end

  def get_value_from_deepest_transaction(name)
    value = self.transactions[name][-1]
    if value
      value[1]
    end
  end

  def in_transaction?
    self.transaction_count > 0;
  end

  def name_in_transaction?(name)
    self.transactions[name]
  end

  def method_missing(m, *args, &block)
    puts "WARNING: '#{m}' is not a recognized command"
  end

end

turo_db = TuroDatabase.new
turo_db.process_input
