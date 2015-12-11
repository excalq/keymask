# Monkey Patch this into Hash and Array.
module KeymaskMethods
  def keymask!(rules)
    km = Keymask.new
    km.set_rules(rules)
    km.filter(self)
  end

  def keymask(rules)
    km = Keymask.new
    km.set_rules(rules)
    hcopy = Marshal.load(Marshal.dump(self)) # Deep dup
    km.filter(hcopy)
  end
end

Hash.send(:include, KeymaskMethods)
Array.send(:include, KeymaskMethods)
