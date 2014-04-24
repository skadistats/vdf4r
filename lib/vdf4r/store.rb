module VDF4R
  class Store < Hash
    def initialize
      super { |h, k| h[k] = Store.new } # defaultdict(dict)
    end

    def traverse(path)
      path.inject(self) { |current, path_component| current[path_component] }
    end
  end
end