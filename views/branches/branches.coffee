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
      $scope.visualizeCommitsDaily()
      $scope.visualizeDayOfWeekDistribution()

  $scope.visualizeCommitsDaily = ->
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

    tooltip = svg.append('text')
        .attr('class', 'tooltip')
        .attr('font-weight', 'bold')
        .attr('dy', 14)

    svg.selectAll('path').data(commitData).enter()
      .append('circle')
        .attr('fill', 'white')
        .attr('stroke', 'black')
        .attr('r', 5)
        .attr('cx', (d) -> x(parseDate.parse(d.key)))
        .attr('cy', (d) -> y(d.values.length))
        .on('mouseover', (d) ->
          d3.select(this).transition()
            .duration(300)
            .attr('r', 8)
            .attr('fill', 'black')
            .attr('stroke', 'black')

          tooltip.text(d.key + ': ' + d.values.length + ' commits')
        )

        .on('mouseout', ->
          d3.select(this).transition()
            .duration(300)
            .attr('r', 5)
            .attr('fill', 'white')
            .attr('stroke', 'black')
        )

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(0, ' + (dimensions.height + 10) + ')')
      .call(xAxis)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(-10,0)')
      .call(yAxis)

  $scope.visualizeDayOfWeekDistribution = ->
    dimensions =
      width: 600
      height: 300

      margins:
        top: 10
        right: 10
        bottom: 40
        left: 50

      pie:
        radius: 100

    parseDate = d3.time.format('%A')
    color = d3.scale.category20c()

    commitData = d3.nest()
      .key((d) ->
        return parseDate(new Date(d.date))
      )
      .sortKeys(d3.ascending)
      .entries($scope.commits)

    pie = d3.layout.pie().value((d) -> d.values.length)

    svg = d3.select('.d3.dow')
      .append('svg:svg')
        .data([commitData])
        .attr('width', dimensions.width + dimensions.margins.left + dimensions.margins.right)
        .attr('height', dimensions.height + dimensions.margins.top + dimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + dimensions.margins.left + ', ' + dimensions.margins.top + ')')

    arc = d3.svg.arc().outerRadius(dimensions.pie.radius)

    slices = svg.selectAll('g.slice').data(pie).enter()
      .append('g')
        .attr('class', 'slice')
        .attr('transform', 'translate(300,150)')

    slices.append('path')
      .attr('fill', (d, i) -> color(i))
      .attr('d', arc)
