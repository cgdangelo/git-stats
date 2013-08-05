app = angular.module('stats', []).
  config ($routeProvider) ->
    $routeProvider
      .when '/branches',
        controller: BranchListCtrl, templateUrl: '/branches/list.html'
      .otherwise
        redirectTo: '/branches'
