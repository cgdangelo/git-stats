app = angular.module('stats', []).
  config ($routeProvider) ->
    $routeProvider.
      when '/',
        controller: BranchesCtrl, templateUrl: '/branches/list.html'
