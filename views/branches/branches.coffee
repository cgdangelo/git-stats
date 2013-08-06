BranchListCtrl = ($scope, $http) ->
  $http.get('/branches')
    .success (data, status) ->
      $scope.status = status
      $scope.branches = data

BranchInfoCtrl = ($scope, $http, $routeParams) ->
  $http.get('/branches/' + $routeParams.branch)
    .success (data, status) ->
      $scope.status = status
      $scope.commits = data
      $scope.visualizeCommits()

  $scope.visualizeCommits = ->
    dimensions =
      width: 500
      height: 300

      margins:
        up: 10
        right: 10
        down: 10
        left: 10

    parseDate = d3.time.format('%Y-%m-%d')

    svg = d3.select('.d3.daily')
      .append('svg:svg')
      .attr('width', dimensions.width)
      .attr('height', dimensions.height)

    commitData = d3.nest()
      .key((d) ->
        return parseDate(new Date(d.date))
      )
      .sortKeys(d3.ascending)
      .entries($scope.commits)

    x = d3.time.scale()
      .domain(d3.extent(commitData, (d) -> parseDate.parse(d.key)))
      .range([0, dimensions.width])

    y = d3.scale.linear()
      .domain([0, d3.max(commitData, (d) -> d.values.length)])
      .range([0, dimensions.height])

    commitLine = d3.svg.line()
      .x((d) ->
        x(parseDate.parse(d.key))
      )
      .y((d) ->
        console.log y(d.values.length)
        y(d.values.length)
      )

    svg.append('path').attr('d', commitLine(commitData))
