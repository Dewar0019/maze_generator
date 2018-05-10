## Setup

1. To run this application you must have ruby `2.5.0` installed. If `rbenv`
is used you can run `rbenv install` from the root directory of this project
to install.

2. Once ruby is installed you must install dependencies with `bundle install`

3. For Database setup you must run `bundle exec rake db:create db:migrate`

## Tests

Run tests to make sure they pass `bundle exec rake test`

## Running the server

Command to run the server `bundle exec rails server`


### Modeling

Mazes are modeled using their `width` and `height` size as dimensions to
the maze. Maze `blockers` are in the form of a `jsonb` data type and
consist of locations that are marked by its key in the form of
`#{y}-#{x}` where y and x is the location in which they are found. These
locations are unreachable and block the user from proceeding to and from
that space.


## API Endpoints

### POST /maze
Creates a solvable maze of random size range from `2..100` with a random
number of blockers  where `blockers < grid_size`

success response:
```
id: Maze id for use in subsequent calls.
height: Height of maze.
width: Width of maze.
```

example response:
```
id: 45
height: 10
width: 8
```


#### GET /maze/{id}/check?x={x position}&y={y position}
Checks the give maze and location to see if within bounds of maze size
and the absence of a blocker. if the location is invalid, a message will
return with 'invalid' and a 200 response code to the user.

success response:
```
valid/invalid
```

`GET /maze/4/check?x=4&y=5`
example response:
```
valid
```


#### POST /maze/{id}/solve
Takes a JSON array with key `solution` and runs through the steps to
determine if route through maze from start to end is correct.

success response:
```
correct/incorrect
```

example JSON body input:
```
{
    "solution": [
        { "x" : 0, "y": 0},
        { "x" : 1, "y": 0},
        { "x" : 1, "y": 1},
        { "x" : 1, "y": 2}
    ]
}
```

example response:
```
correct
```




