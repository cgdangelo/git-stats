app = angular.module('stats', []).
  config ($routeProvider) ->
    $routeProvider
      .when '/branches',
        controller: BranchListCtrl, templateUrl: '/branches/list.html'
      .when '/branches/:branch',
        controller: BranchInfoCtrl, templateUrl: '/branches/info.html'
      .otherwise
        redirectTo: '/branches'
