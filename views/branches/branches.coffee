BranchesCtrl = ($scope, $http) ->
  $http(
    method: 'get'
    url: '/branches'
  ).
  success (data, status) ->
    $scope.status = status
    $scope.branches = data
