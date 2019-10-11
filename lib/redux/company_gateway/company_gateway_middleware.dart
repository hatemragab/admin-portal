import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invoiceninja_flutter/data/models/company_gateway_model.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';
import 'package:invoiceninja_flutter/redux/app/app_middleware.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/company_gateway/company_gateway_screen.dart';
import 'package:invoiceninja_flutter/ui/company_gateway/edit/company_gateway_edit_vm.dart';
import 'package:invoiceninja_flutter/ui/company_gateway/view/company_gateway_view_vm.dart';
import 'package:invoiceninja_flutter/redux/company_gateway/company_gateway_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/data/repositories/company_gateway_repository.dart';

List<Middleware<AppState>> createStoreCompanyGatewaysMiddleware([
  CompanyGatewayRepository repository = const CompanyGatewayRepository(),
]) {
  final viewCompanyGatewayList = _viewCompanyGatewayList();
  final viewCompanyGateway = _viewCompanyGateway();
  final editCompanyGateway = _editCompanyGateway();
  final loadCompanyGateways = _loadCompanyGateways(repository);
  final loadCompanyGateway = _loadCompanyGateway(repository);
  final saveCompanyGateway = _saveCompanyGateway(repository);
  final archiveCompanyGateway = _archiveCompanyGateway(repository);
  final deleteCompanyGateway = _deleteCompanyGateway(repository);
  final restoreCompanyGateway = _restoreCompanyGateway(repository);

  return [
    TypedMiddleware<AppState, ViewCompanyGatewayList>(viewCompanyGatewayList),
    TypedMiddleware<AppState, ViewCompanyGateway>(viewCompanyGateway),
    TypedMiddleware<AppState, EditCompanyGateway>(editCompanyGateway),
    TypedMiddleware<AppState, LoadCompanyGateways>(loadCompanyGateways),
    TypedMiddleware<AppState, LoadCompanyGateway>(loadCompanyGateway),
    TypedMiddleware<AppState, SaveCompanyGatewayRequest>(saveCompanyGateway),
    TypedMiddleware<AppState, ArchiveCompanyGatewayRequest>(archiveCompanyGateway),
    TypedMiddleware<AppState, DeleteCompanyGatewayRequest>(deleteCompanyGateway),
    TypedMiddleware<AppState, RestoreCompanyGatewayRequest>(restoreCompanyGateway),
  ];
}

Middleware<AppState> _editCompanyGateway() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) async {

    final action = dynamicAction as EditCompanyGateway;

    if (!action.force && hasChanges(
        store: store, context: action.context, action: action)) {
      return;
    }

    next(action);

    store.dispatch(UpdateCurrentRoute(CompanyGatewayEditScreen.route));

    if (isMobile(action.context)) {
        final companyGateway =
            await Navigator.of(action.context).pushNamed(CompanyGatewayEditScreen.route);

        if (action.completer != null && companyGateway != null) {
          action.completer.complete(companyGateway);
        }
    }
  };
}

Middleware<AppState> _viewCompanyGateway() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) async {

      final action = dynamicAction as ViewCompanyGateway;

    if (!action.force && hasChanges(
        store: store, context: action.context, action: action)) {
      return;
    }


    next(action);

    store.dispatch(UpdateCurrentRoute(CompanyGatewayViewScreen.route));

    if (isMobile(action.context)) {
        Navigator.of(action.context).pushNamed(CompanyGatewayViewScreen.route);
    }
  };
}

Middleware<AppState> _viewCompanyGatewayList() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as ViewCompanyGatewayList;

    if (!action.force && hasChanges(
        store: store, context: action.context, action: action)) {
      return;
    }

    next(action);

    if (store.state.companyGatewayState.isStale) {
      store.dispatch(LoadCompanyGateways());
    }

    store.dispatch(UpdateCurrentRoute(CompanyGatewayScreen.route));

    if (isMobile(action.context)) {
      Navigator.of(action.context).pushNamedAndRemoveUntil(
          CompanyGatewayScreen.route, (Route<dynamic> route) => false);
    }
  };
}

Middleware<AppState> _archiveCompanyGateway(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
  final action = dynamicAction as ArchiveCompanyGatewayRequest;
    final origCompanyGateway = store.state.companyGatewayState.map[action.companyGatewayId];
    repository
        .saveData(store.state.credentials,
            origCompanyGateway, EntityAction.archive)
        .then((CompanyGatewayEntity companyGateway) {
      store.dispatch(ArchiveCompanyGatewaySuccess(companyGateway));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(ArchiveCompanyGatewayFailure(origCompanyGateway));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _deleteCompanyGateway(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as DeleteCompanyGatewayRequest;
    final origCompanyGateway = store.state.companyGatewayState.map[action.companyGatewayId];
    repository
        .saveData(store.state.credentials,
            origCompanyGateway, EntityAction.delete)
        .then((CompanyGatewayEntity companyGateway) {
      store.dispatch(DeleteCompanyGatewaySuccess(companyGateway));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(DeleteCompanyGatewayFailure(origCompanyGateway));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _restoreCompanyGateway(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
  final action = dynamicAction as RestoreCompanyGatewayRequest;
    final origCompanyGateway = store.state.companyGatewayState.map[action.companyGatewayId];
    repository
        .saveData(store.state.credentials,
            origCompanyGateway, EntityAction.restore)
        .then((CompanyGatewayEntity companyGateway) {
      store.dispatch(RestoreCompanyGatewaySuccess(companyGateway));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(RestoreCompanyGatewayFailure(origCompanyGateway));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _saveCompanyGateway(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as SaveCompanyGatewayRequest;
    repository
        .saveData(
            store.state.credentials, action.companyGateway)
        .then((CompanyGatewayEntity companyGateway) {
      if (action.companyGateway.isNew) {
        store.dispatch(AddCompanyGatewaySuccess(companyGateway));
      } else {
        store.dispatch(SaveCompanyGatewaySuccess(companyGateway));
      }
    final companyGatewayUIState = store.state.companyGatewayUIState;
    if (companyGatewayUIState.saveCompleter != null) {
      companyGatewayUIState.saveCompleter.complete(companyGateway);
    }
    }).catchError((Object error) {
      print(error);
      store.dispatch(SaveCompanyGatewayFailure(error));
      action.completer.completeError(error);
    });

    next(action);
  };
}

Middleware<AppState> _loadCompanyGateway(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
  final action = dynamicAction as LoadCompanyGateway;
    final AppState state = store.state;

    if (state.isLoading) {
      next(action);
      return;
    }

    store.dispatch(LoadCompanyGatewayRequest());
    repository
        .loadItem(state.credentials, action.companyGatewayId)
        .then((companyGateway) {
      store.dispatch(LoadCompanyGatewaySuccess(companyGateway));

      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadCompanyGatewayFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _loadCompanyGateways(CompanyGatewayRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
  final action = dynamicAction as LoadCompanyGateways;
    final AppState state = store.state;

    if (!state.companyGatewayState.isStale && !action.force) {
      next(action);
      return;
    }

    if (state.isLoading) {
      next(action);
      return;
    }

    final int updatedAt = (state.companyGatewayState.lastUpdated / 1000).round();

    store.dispatch(LoadCompanyGatewaysRequest());
    repository
        .loadList(state.credentials, updatedAt)
        .then((data) {
      store.dispatch(LoadCompanyGatewaysSuccess(data));

      if (action.completer != null) {
        action.completer.complete(null);
      }
      /*
      if (state.productState.isStale) {
        store.dispatch(LoadProducts());
      }
      */
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadCompanyGatewaysFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}
