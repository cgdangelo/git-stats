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
      $scope.visualizeTimeOfDayDistribution()
      $scope.visualizeAuthors()

  $scope.svgDimensions =
    width: 600
    height: 300

    margins:
      top: 10
      right: 10
      bottom: 40
      left: 50

  $scope.groupByDate = (data, format) ->
    d3.nest()
      .key((d) ->
        format(new Date(d.date))
      )
      .sortKeys(d3.ascending)
      .entries(data)

  $scope.visualizeCommitsDaily = ->
    svg = d3.select('.d3.daily')
      .append('svg:svg')
        .attr('width', $scope.svgDimensions.width + $scope.svgDimensions.margins.left + $scope.svgDimensions.margins.right)
        .attr('height', $scope.svgDimensions.height + $scope.svgDimensions.margins.top + $scope.svgDimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + $scope.svgDimensions.margins.left + ', ' + $scope.svgDimensions.margins.top + ')')

    parseDate = d3.time.format('%Y-%m-%d')
    commitData = $scope.groupByDate($scope.commits, parseDate)

    x = d3.time.scale()
      .domain(d3.extent(commitData, (d) -> parseDate.parse(d.key)))
      .range([0, $scope.svgDimensions.width])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')

    y = d3.scale.linear()
      .domain([0, d3.max(commitData, (d) -> d.values.length)])
      .range([$scope.svgDimensions.height, 0])

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

    blobs = svg.selectAll('path').data(commitData).enter()
      .append('g')
        .attr('class', 'blob')

    blobs.append('circle')
      .attr('fill', 'white')
      .attr('stroke', 'black')
      .attr('r', 5)
      .attr('cx', (d) -> x(parseDate.parse(d.key)))
      .attr('cy', (d) -> y(d.values.length))
      .on('mouseover', ->
        d3.select(@).transition(300)
          .attr('r', 12)
          .attr('fill', 'steelblue')

        d3.select(this.nextSibling)
          .style('display', 'block')
          .transition(300)
            .style('opacity', 1)
      )
      .on('mouseout', ->
        d3.select(@).transition(300)
          .attr('r', 5)
          .attr('fill', 'white')

        d3.select(this.nextSibling)
          .transition(300)
            .style('opacity', 0)
            .style('display', 'block')
      )

    blobs.append('text')
      .text((d) -> d.values.length)
      .style('display', 'none')
      .style('opacity', '0')
      .attr('class', 'tooltip')
      .attr('text-anchor', 'middle')
      .attr('x', (d) -> x(parseDate.parse(d.key)))
      .attr('y', (d) -> y(d.values.length))
      .attr('dx', -2)
      .attr('dy', '-15')

    tooltip = svg.append('text')
        .attr('class', 'tooltip')
        .attr('font-weight', 'bold')
        .attr('dy', 14)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(0, ' + ($scope.svgDimensions.height + 10) + ')')
      .call(xAxis)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(-10,0)')
      .call(yAxis)

  $scope.visualizeDayOfWeekDistribution = ->
    $scope.svgDimensions.pie = radius: 150

    color = d3.scale.category20c()

    commitData = $scope.groupByDate($scope.commits, d3.time.format('%A'))

    pie = d3.layout.pie().value((d) -> d.values.length)

    svg = d3.select('.d3.dow')
      .append('svg:svg')
        .data([commitData])
        .attr('width', $scope.svgDimensions.width + $scope.svgDimensions.margins.left + $scope.svgDimensions.margins.right)
        .attr('height', $scope.svgDimensions.height + $scope.svgDimensions.margins.top + $scope.svgDimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + $scope.svgDimensions.margins.left + ', ' + $scope.svgDimensions.margins.top + ')')

    arc = d3.svg.arc()
        .outerRadius($scope.svgDimensions.pie.radius)
        .innerRadius(0)

    slices = svg.selectAll('g.slice').data(pie).enter()
      .append('g')
        .attr('class', 'slice')
        .attr('transform', 'translate(300,150)')

    slices.append('path')
      .attr('fill', (d, i) -> color(i))
      .attr('d', arc)

    slices.append('text')
      .attr('transform', (d, i) ->
        'translate(' + arc.outerRadius($scope.svgDimensions.pie.radius + 25).centroid(d) + ')'
      )
      .attr('text-anchor', 'middle')
      .text((d) -> d.data.key)

  $scope.visualizeAuthors = ->
    parseDate = d3.time.format('%Y-%m-%d')

    svg = d3.select('.d3.authors')
      .append('svg:svg')
        .attr('width', $scope.svgDimensions.width + $scope.svgDimensions.margins.left + $scope.svgDimensions.margins.right)
        .attr('height', $scope.svgDimensions.height + $scope.svgDimensions.margins.top + $scope.svgDimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + $scope.svgDimensions.margins.left + ', ' + $scope.svgDimensions.margins.top + ')')

    commitData = d3.nest()
      .key((d) ->
          d.author.name
      )
      .entries($scope.commits)
      .sort((a, b) ->
        if a.values.length > b.values.length
          -1
        else if a.values.length < b.values.length
          1
        else 0
    )

    x = d3.scale.linear()
        .domain(d3.extent(commitData, (d) -> d.values.length))
        .range([0, $scope.svgDimensions.width - 150])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')

    y = d3.scale.ordinal()
        .domain(commitData.map((d) -> d.key))
        .rangeRoundBands([$scope.svgDimensions.margins.top, $scope.svgDimensions.height])

    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')

    bars = svg.selectAll('g.bar').data(commitData).enter()
      .append('g')
        .attr('class', 'bar')

    bars.append('rect')
      .attr('x', (d3.max(commitData, (d) -> d.key.length) * 3) + 10)
      .attr('y', (d, i) -> y(d.key) + 20 + $scope.svgDimensions.margins.top)
      .attr('width', (d) -> x(d.values.length))
      .attr('height', '15px')
      .attr('fill', 'steelblue')

    bars.append('text')
      .text((d) ->
        d.values.length
      )
      .attr('text-anchor', 'start')
      .attr('x', (d) -> x(d.values.length) + $scope.svgDimensions.margins.left + 15)
      .attr('y', (d) -> y(d.key) + 20 + $scope.svgDimensions.margins.top + 13)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(' + ((d3.max(commitData, (d) -> d.key.length) * 3) + 10) + ',' + ($scope.svgDimensions.height + 10) + ')')
      .call(xAxis)

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(' + (d3.max(commitData, (d) -> d.key.length) * 3) + ',0)')
      .call(yAxis)

  $scope.visualizeTimeOfDayDistribution = ->
    svg = d3.select('.d3.tod')
      .append('svg:svg')
        .attr('width', $scope.svgDimensions.width + $scope.svgDimensions.margins.left + $scope.svgDimensions.margins.right)
        .attr('height', $scope.svgDimensions.height + $scope.svgDimensions.margins.top + $scope.svgDimensions.margins.bottom)
      .append('g')
        .attr('transform', 'translate(' + $scope.svgDimensions.margins.left + ', ' + $scope.svgDimensions.margins.top + ')')

    commitData = $scope.groupByDate($scope.commits, d3.time.format('%H'))
