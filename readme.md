# Instructions

## Executing the program

* Download MineBlastEvaluator package

```
app/mine_blast_evaluator.rb
lib/mines_file_parser.rb
spec/mine_blast_evaluator_spec.rb
example_mines.txt
seed_mines.txt
```

* Execute the program from within the same directory where the program files are saved.

* Pass the mine data to the program via a text file (e.g. `example_mines.txt`):

```
$ ruby app/mine_blast_evaluator.rb example_mines.txt
```

* The program's output is saved to a file called `sorted_mines.txt`

## Test coverage

* To run the test suite, install the `Rspec` gem via `$ gem install rspec`

* Execute the test suite by calling rspec and passing the spec file:

```
$ rspec spec/mine_blast_evaluator_spec.rb
```
