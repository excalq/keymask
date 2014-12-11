### Keymask Gem

_December 10, 2014 Arthur Ketcham, written for GoWatchIt.com_

_Version: 0.0.1_

#### What

  To ensure certain attributes are removed from a data structure
  (such as a JSON API response body), instead of hard-coding complex
  hash manipulations, this allows you to specifiy a set of "rules",
  which will be used to filter out matching attributes by thier keys.

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
  be a string matching a key. (support for symbol keys is TODO later)
  * Multiple rules in the rule hash are fine.
  * Anything left of the final item can be a string, "*", or "$".
  * "*" means to match any key at that level.
  * "$" means to apply rules to each element in an array.


`{"Remove foo from all items"=>"$.foo"}` will transform:
```
    [{"foo"=>4, "bar"=>8}, {"foo"=>16, "bar"=>0}, {"foo"=>[1,2,3], "tar"=>{...}}]
```
  into
```
    [{"bar"=>8}, {"bar"=>0}, {"tar"=>{...}}]
```

#### But wait there's more!

  This gem also adds two methods to Hash and Array:
  * `(Hash|Array)#keymask(ruleset)` Returns a copy of self, with the ruleset applied
  * `(Hash|Array)#keymask!(ruleset)` Performs ruleset on self, returning result. (faster)


#### To Be Completed
  * Support for symbolized keys
  * TESTS!!!