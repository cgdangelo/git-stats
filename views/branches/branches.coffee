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
      width: 600
      height: 300

      margins:
        top: 10
        right: 10
        bottom: 40
        left: 50

    parseDate = d3.time.format('%Y-%m-%d')

    svg = d3.select('.d3.daily')
      .append('svg:svg')
        .attr('width', dimensions.width + dimensions.margins.left + dimensions.margins.right)
        .attr('height', dimensions.height + dimensions.margins.top + dimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + dimensions.margins.left + ', ' + dimensions.margins.top + ')')

    commitData = d3.nest()
      .key((d) ->
        return parseDate(new Date(d.date))
      )
      .sortKeys(d3.ascending)
      .entries($scope.commits)

    x = d3.time.scale()
      .domain(d3.extent(commitData, (d) -> parseDate.parse(d.key)))
      .range([0, dimensions.width])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')

    y = d3.scale.linear()
      .domain([0, d3.max(commitData, (d) -> d.values.length)])
      .range([dimensions.height, 0])

    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')
      .ticks(10)

    commitLine = d3.svg.line()
      .x((d) ->
        x(parseDate.parse(d.key))
      )
      .y((d) -> y(d.values.length))

    svg.append('path').attr('d', commitLine(commitData))

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(0, ' + (dimensions.height + 10) + ')')
      .call(xAxis)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(-10,0)')
      .call(yAxis)
