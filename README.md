### Keymask Gem

_December 10, 2014 Arthur Ketcham_

_Version: 0.0.1_

#### What

  To ensure certain attributes are removed from a data structure
  (such as a JSON API response body), instead of hard-coding complex
  hash manipulations, this allows you to specify a set of "rules",
  which will be used to filter out matching attributes by their keys.

#### How
 You will provide a hash of blacklist rules. The keys being a
  human-readable description, and the values being the rules.
  rules need to be strings in a specific format. As an example:
  A rule of `{"My Rule" => "*.bar"}` will remove the element key with "bar"
  from
```
{"foo"=>{"bar"=>[1,2,3]}, "yoo"=>{"bar"=>100, "baz"=>100}}
```
  producing the result: `{"foo"=>{}, "yoo"=>{"baz"=>100}}`

  In the rules, a dot (.) separates each level. The final item must
  be a string matching a key. (Symbolic keys aren't supported yet)
  * Multiple rules in the rule hash are fine.
  * Anything left of the final item can be a string, "*", or "$".
  * "*" means to match any key at that level.
  * "$" means to apply rules to each element in an array.


A rule such as `{"Remove foo from all items"=>"$.foo"}` will transform:
```
[{"foo"=>4, "bar"=>8}, {"foo"=>16, "bar"=>0}, {"foo"=>[1,2,3], "car"=>{...}}]
```
into
```
[{"bar"=>8}, {"bar"=>0}, {"car"=>{...}}]
```

#### But wait there's more!

  This gem also adds two methods to Hash and Array:
  * `(Hash|Array)#keymask(ruleset)` Returns a copy of self, with the ruleset applied
  * `(Hash|Array)#keymask!(ruleset)` Performs ruleset on self, returning result. (faster)


### General Usage

Let's create a hash containing two items: an array of hashes, and a nested hash.
```
data = <<END
{
  "first"=>
  [
    {"second"=>"value", "foo"=>"value"},
    {"second"=>"value", "foo"=>"value"}
  ],
  "last"=>
    {"second"=>"value", "foo"=>"value", "baz"=>"value"}
}
END
```

Next, we'll create a set of rules using dot-notation. The key is a label, and the
value is the rule. In this case, we'll use two rules, one to cover an array on the
second level, another to cover a hash on the second level.
```
rules = {"Drop the second level key in array-of-hashes" => "*.$.second",
         "Drop the second level key in a nested hash" => "*.second"}
```
Of course, you can use nested keys for specific targeting, e.g. "first.second.third"


Apply the keymask (Method 1)
```
keymask = Keymask.new
keymask.set_rules(rules)
keymask.filter(data)
  # returns:
  {"first"=>[{"foo"=>"value"}, {"foo"=>"value"}], "bar"=>{"foo"=>"value", "baz"=>"value"}}
```

Apply the keymask (Method 2)
```
data.keymask!(rules)
   # returns:
  {"first"=>[{"foo"=>"value"}, {"foo"=>"value"}], "bar"=>{"foo"=>"value", "baz"=>"value"}}
```
This gem adds `keymask` and `keymask!` methods to Hash and Array.

`#keymask!` operates directly on the object, saving memory, as `#keymask` must do a deep clone
of the object.


#### To Be Completed
  * Support for symbolized keys
  * TESTS!!!
