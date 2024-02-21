import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/callback/popcenter/popcenter_list_response.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/list_filter_user_model.dart';
import 'package:new_popbox/core/models/payload/parcel_for_you_history_payload.dart';
import 'package:new_popbox/core/models/payload/popcenter_list_payload.dart';
import 'package:new_popbox/core/models/payload/popsafe_history_payload.dart';
import 'package:new_popbox/core/models/payload/unfinish_parcel.dart';
import 'package:new_popbox/core/models/popbox_service.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/core/viewmodel/parcel_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/popcenter_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/popsafe_viewmodel.dart';
import 'package:new_popbox/ui/item/location_filter_item.dart';
import 'package:new_popbox/ui/item/transaction_item.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class TransactionNewPage extends StatefulWidget {
  final bool isHeader;
  final bool isHome;
  final bool isSearchable;
  final bool isShowcase;
  final String from;
  final GlobalKey keyThree;

  const TransactionNewPage(
      {Key key,
      this.isHome,
      this.isHeader,
      this.isSearchable,
      this.isShowcase,
      this.from,
      this.keyThree})
      : super(key: key);
  @override
  State<TransactionNewPage> createState() => _TransactionNewPageState();
}

class _TransactionNewPageState extends State<TransactionNewPage> {
  List<UnfinishParcelData> unfinishParcelList;
  UserLoginData userData = new UserLoginData();

  int checkedIndex = 0;
  final PageController controller = new PageController();
  List<Widget> itemOfType = [];
  List<ParcelForYouHistoryData> dummyparcelHistoryList = [];
  List<PopsafeHistoryData> dummypopsafeHistoryList = [];
  List<PopcenterHistoryData> dummypopcenterHistoryList = [];

  //Popsafe
  int pagePaginationPopsafe = 1;
  List<PopsafeHistoryData> popsafeHistoryList = [];
  List<PopsafeHistoryData> listAllPopsafeForFilter = [];
  int totalPagePaginationPopsafe;
  List<PopsafeHistoryData> myListPopsafeHome = [];
  List myListPaginationPopsafe = [];
  int currentMaxPaginationPopsafe = 10;
  bool popsafeCheckedCreated = false;
  bool popsafeCheckedInstore = false;
  bool popsafeCheckedOverdue = false;
  bool popsafeCheckedExpired = false;
  bool popsafeCheckedCancel = false;
  bool popsafeCheckedCustomertaken = false;
  String _popsafeFilterCreated = "";
  String _popsafeFilterInstore = "";
  String _popsafeFilterOverdue = "";
  String _popsafeFilterCustomertaken = "";
  String _popsafeFilterExpired = "";
  String _popsafeFilterCancel = "";
  bool isFilterPopsafe = false;

  //Popcenter
  int pagePaginationPopcenter = 1;
  List<PopcenterHistoryData> popcenterList = [];
  List<PopcenterHistoryData> myListPaginationPopcenter = [];
  List<PopcenterHistoryData> listAllPopcenterForFilter = [];
  int totalPagePaginationPopcenter;
  int currentMaxPaginationPopcenter = 10;
  bool popcenterCheckedInbound = false;
  bool popcenterCheckedOutbound = false;
  bool popcenterCheckedOutboundCourier = false;
  bool popcenterCheckedOutboundOperator = false;
  bool popcenterCheckedDestroy = false;
  bool popcenterCheckedInboundLocker = false;
  String _popcenterFilterInbound = "";
  String _popcenterFilterOutbound = "";
  String _popcenterFilterOutboundCourier = "";
  String _popcenterFilterOutboundOperator = "";
  String _popcenterFilterDestroy = "";
  String _popcenterFilterInboundLocker = "";
  bool isFilterPopcenter = false;

  //Parcel
  int pagePagination = 1;
  List<ParcelForYouHistoryData> parcelHistoryList = [];
  List<ParcelForYouHistoryData> listAllParcelForFilter = [];
  int totalPagePagination;
  List myListPagination = [];
  int currentMaxPagination = 10;
  List<ListFilterUser> listOfFilterUser = [];
  List<String> listOfFilterFlag = [];
  bool parcelCheckedOverdue = false;
  bool parcelCheckedComplete = false;
  bool parcelCheckedInstore = false;
  bool parcelCheckedCustomertaken = false;
  bool parcelCheckedCouriertaken = false;
  bool parcelCheckedOperatortaken = false;
  bool parcelCheckedCanceled = false;
  bool isFilterParcel = false;

  String _parcelFilterOverdue = "";
  String _parcelFilterComplete = "";
  String _parcelFilterInstore = "";
  String _parcelFilterCustomertaken = "";
  String _parcelFilterCouriertaken = "";
  String _parcelFilterOperatortaken = "";
  String _parcelFilterCanceled = "";

  //Filter Flag
  bool flagLastmile = false;
  String _flagFilterLastmile = "";
  bool flagPopsafe = false;
  String _flagFilterPopsafe = "";
  bool flagFnb = false;
  String _flagFilterFnb = "";

  //Search
  bool isSearch = false;
  bool isSearchPopsafe = false;
  bool isSearchPopcenter = false;
  List<dynamic> myListSearch = [];
  var parcelModel;
  var popsafeModel;
  var popcenterModel;
  //
  bool isParcelFilterbyStatus = true;
  bool isParcelFilterbyType = true;

  @override
  void initState() {
    //ViewModel
    parcelModel = Provider.of<ParcelViewModel>(context, listen: false);
    popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);
    popcenterModel = Provider.of<PopcenterViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await SharedPreferencesService().getUser();

      if (userData != null &&
          userData.isGuest == false &&
          widget.isShowcase == false) {
        if (widget.isHome) {
          //Unfinish Parcel
          UnfinishParcelPayload unfinishParcelPayload =
              new UnfinishParcelPayload();
          unfinishParcelPayload.token = GlobalVar.API_TOKEN;
          unfinishParcelPayload.limit = 10;
          unfinishParcelPayload.sessionId = userData.sessionId;

          await parcelModel.unfinishParcelHistory(
            unfinishParcelPayload,
            context,
            onSuccess: (response) {
              unfinishParcelList = response.data;
            },
            onError: (response) {
              unfinishParcelList = [];
            },
          );
          print("Hit Popsafe on going");
          //Popsafe
          PopsafeHistoryPayload popsafeHistoryPayload =
              new PopsafeHistoryPayload();

          popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
          popsafeHistoryPayload.page = pagePaginationPopsafe;
          popsafeHistoryPayload.sessionId = userData.sessionId;
          popsafeHistoryPayload.status = "ongoing";

          await popsafeModel.getPopsafeHistoryList(
            popsafeHistoryPayload,
            context,
            onSuccess: (response) {
              setState(() {
                popsafeHistoryList = [];
                if (response != null && response.data != null) {
                  popsafeHistoryList = response.data;
                  totalPagePaginationPopsafe = response.totalpage;
                  myListPopsafeHome = response.data;

                  myListPaginationPopsafe = response.data;
                  //TO DO DEV
                  _loadMoreNewPagePopsafe();
                }
              });
            },
            onError: (response) {
              setState(() {
                popsafeHistoryList = [];
              });
            },
          );
          //POPCENTER Home
          PopcenterListPayload popcenterListPayload =
              new PopcenterListPayload();

          popcenterListPayload.authorization = GlobalVar.API_TOKEN_POPCENTER;
          popcenterListPayload.page = pagePaginationPopcenter;
          popcenterListPayload.phoneNumber = userData.phone;
          popcenterListPayload.timeInbound = null;
          popcenterListPayload.status = [
            "INBOUND_POPCENTER",
            "INBOUND_POPCENTER_LOCKER"
          ];
          await popcenterModel.popcenterList(
            popcenterListPayload,
            context,
            onSuccess: (response) {
              setState(() {
                popcenterList = [];
                popcenterList.clear();
                if (response != null && response.data.data != null) {
                  popcenterList = response.data.data;
                  totalPagePaginationPopcenter =
                      response.data.paginate.totalPaginate;
                  myListPaginationPopcenter = response.data.data;
                }
              });
            },
            onError: (response) {
              setState(() {
                popcenterList = [];
              });
            },
          );
        } else {
          print("HIT PARCEL");
          //PARCEL
          ParcelForYouHistoryPayload parcelForYouHistoryPayload =
              new ParcelForYouHistoryPayload();
          parcelForYouHistoryPayload.token = GlobalVar.API_TOKEN;
          parcelForYouHistoryPayload.page = pagePagination.toString();
          parcelForYouHistoryPayload.isComplete = "all";

          parcelForYouHistoryPayload.sessionId = userData.sessionId;
          parcelForYouHistoryPayload.status = "";
          await parcelModel.getParcelHistoryList(
            parcelForYouHistoryPayload,
            context,
            onSuccess: (response) {
              //debug rafi
              if (!mounted) return;
              //
              setState(() {
                parcelHistoryList = [];
                parcelHistoryList.clear();
                listAllParcelForFilter = [];
                listAllParcelForFilter.clear();
                if (response != null && response.data != null) {
                  parcelHistoryList = response.data;
                  totalPagePagination = response.totalpage;
                  myListPagination = response.data;
                  listAllParcelForFilter = response.data;
                  _loadMoreNewPage();
                }
              });
            },
            onError: (response) {
              setState(() {
                parcelHistoryList = [];
              });
            },
          );
          print("HIT Popsafe");
          //Popsafe
          PopsafeHistoryPayload popsafeHistoryPayload =
              new PopsafeHistoryPayload();

          popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
          popsafeHistoryPayload.page = pagePaginationPopsafe;
          popsafeHistoryPayload.sessionId = userData.sessionId;
          popsafeHistoryPayload.status = "all";

          await popsafeModel.getPopsafeHistoryList(
            popsafeHistoryPayload,
            context,
            onSuccess: (response) {
              setState(() {
                popsafeHistoryList = [];
                popsafeHistoryList.clear();
                listAllPopsafeForFilter = [];
                listAllPopsafeForFilter.clear();
                if (response != null && response.data != null) {
                  popsafeHistoryList = response.data;
                  totalPagePaginationPopsafe = response.totalpage;
                  myListPopsafeHome = response.data;
                  listAllPopsafeForFilter = response.data;

                  myListPaginationPopsafe = response.data;

                  _loadMoreNewPagePopsafe();
                }
              });
            },
            onError: (response) {
              setState(() {
                popsafeHistoryList = [];
              });
            },
          );

          //POPCENTER
          PopcenterListPayload popcenterListPayload =
              new PopcenterListPayload();

          popcenterListPayload.authorization = GlobalVar.API_TOKEN_POPCENTER;
          popcenterListPayload.page = pagePaginationPopcenter;
          popcenterListPayload.phoneNumber = userData.phone;
          popcenterListPayload.timeInbound = null;
          popcenterListPayload.status = [];
          await popcenterModel.popcenterList(
            popcenterListPayload,
            context,
            onSuccess: (response) {
              setState(() {
                popcenterList = [];
                popcenterList.clear();
                if (response != null && response.data.data != null) {
                  popcenterList = response.data.data;
                  totalPagePaginationPopcenter =
                      response.data.paginate.totalPaginate;
                  myListPaginationPopcenter = response.data.data;
                  _loadMoreNewPagePopcenter();
                }
              });
            },
            onError: (response) {
              setState(() {
                popcenterList = [];
              });
            },
          );
        }
      } else {}
    });

    super.initState();
  }

  @override
  void dispose() {
    myListPagination = [];
    parcelHistoryList = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHome == true) {
      if (checkedIndex == 0 && widget.isShowcase == false) {
        return unfinishParcelWidget();
      } else if (checkedIndex == 1) {
        return homePopsafeWidget();
      } else if (checkedIndex == 2) {
        return homePopcenterWidget();
      } else {
        return noTransactionData(
            widget.keyThree, widget.isShowcase, widget.isHeader);
      }
    } else {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title: AppLocalizations.of(context).translate(LanguageKeys.seeAll),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: RefreshIndicator(
            onRefresh: () {
              if (checkedIndex == 0) {
                return _refresh();
              } else if (checkedIndex == 1) {
                return _refreshPopsafe();
              } else {
                return _refreshPopCenter();
              }
            },
            child: ListView(
              children: [
                transactionHeader(
                    widget.keyThree, widget.isShowcase, widget.isHeader),
                SizedBox(height: 15),
                filterTransaction(),
                if (checkedIndex == 0)
                  allParcelWidget(context)
                else if (checkedIndex == 1)
                  allPopsafeWidget(context)
                else
                  allPopcenterWidget(context)
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget allPopcenterWidget(BuildContext context) {
    return Consumer<PopcenterViewModel>(
      builder: (context, popcenterModel, _) {
        if (popcenterModel.loading) {
          return cartShimmerView(context);
        } else if (myListPaginationPopcenter.length > 0) {
          return Container(
            height: (widget.from == "parcel")
                ? MediaQuery.of(context).size.height * 0.58
                : MediaQuery.of(context).size.height * 0.63,
            padding: const EdgeInsets.only(top: 4.0),
            child: LoadMore(
              isFinish: (isSearch || isFilterParcel)
                  ? myListPaginationPopcenter.length ==
                      myListPaginationPopcenter.length
                  : currentMaxPaginationPopcenter >= popcenterList.length,
              onLoadMore:
                  (isSearch || isFilterParcel) ? null : _loadMorePopcenter,
              whenEmptyLoad: false,
              delegate: DefaultLoadMoreDelegate(),
              textBuilder: DefaultLoadMoreTextBuilder.english,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (isSearch || isFilterParcel)
                      ? myListPaginationPopcenter.length
                      : (currentMaxPaginationPopcenter <= 10)
                          ? myListPaginationPopcenter.length
                          : currentMaxPaginationPopcenter,
                  itemBuilder: (context, position) {
                    PopcenterHistoryData item =
                        myListPaginationPopcenter[position];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 3.0),
                      child: TransactionItem(
                        type: 'popcenter',
                        popcenter: item,
                      ),
                    );
                  }),
            ),
          );
        } else {
          return noTransactionData(widget.keyThree, widget.isShowcase, false);
        }
      },
    );
  }

  Widget allParcelWidget(BuildContext context) {
    return Consumer<ParcelViewModel>(
      builder: (context, parcelModel, _) {
        if (parcelModel.loading) {
          return cartShimmerView(context);
        } else if (myListPagination.length > 0) {
          return Container(
            height: (widget.from == "parcel")
                ? MediaQuery.of(context).size.height * 0.58
                : MediaQuery.of(context).size.height * 0.63,
            padding: const EdgeInsets.only(top: 4.0),
            child: LoadMore(
              isFinish: (isSearch || isFilterParcel)
                  ? myListPagination.length == myListPagination.length
                  : currentMaxPagination >= parcelHistoryList.length,
              onLoadMore: (isSearch || isFilterParcel) ? null : _loadMore,
              whenEmptyLoad: false,
              delegate: DefaultLoadMoreDelegate(),
              textBuilder: DefaultLoadMoreTextBuilder.english,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (isSearch || isFilterParcel)
                      ? myListPagination.length
                      : (currentMaxPagination <= 10)
                          ? myListPagination.length
                          : currentMaxPagination,
                  itemBuilder: (context, position) {
                    ParcelForYouHistoryData parcelForYouHistoryData =
                        myListPagination[position];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 3.0),
                      child: TransactionItem(
                        type: 'parcel',
                        parcel: parcelForYouHistoryData,
                      ),
                    );
                  }),
            ),
          );
        } else {
          return noTransactionData(widget.keyThree, widget.isShowcase, false);
        }
      },
    );
  }

  Widget allPopsafeWidget(BuildContext context) {
    return Consumer<PopsafeViewModel>(
      builder: (context, popsafeModel, _) {
        if (popsafeModel.loading) {
          return cartShimmerView(context);
        } else if (myListPaginationPopsafe.length > 0) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.63,
            padding: const EdgeInsets.only(top: 4.0),
            child: LoadMore(
              isFinish: (isSearchPopsafe || isFilterPopsafe)
                  ? myListPaginationPopsafe.length ==
                      myListPaginationPopsafe.length
                  : currentMaxPaginationPopsafe >= popsafeHistoryList.length,
              onLoadMore: (isSearchPopsafe || isFilterPopsafe)
                  ? null
                  : _loadMorePopsafe,
              whenEmptyLoad: false,
              delegate: DefaultLoadMoreDelegate(),
              textBuilder: DefaultLoadMoreTextBuilder.english,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (isSearch || isFilterPopsafe)
                      ? myListPaginationPopsafe.length
                      : (currentMaxPaginationPopsafe <= 10)
                          ? myListPaginationPopsafe.length
                          : currentMaxPaginationPopsafe,
                  itemBuilder: (context, position) {
                    PopsafeHistoryData popsafeHistoryData =
                        myListPaginationPopsafe[position];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 3.0),
                      child: TransactionItem(
                        type: 'popsafe',
                        popsafe: popsafeHistoryData,
                      ),
                    );
                  }),
            ),
          );
        } else {
          return noTransactionData(widget.keyThree, widget.isShowcase, false);
        }
      },
    );
  }

  Widget unfinishParcelWidget() {
    return RefreshIndicator(
      onRefresh: _refreshUnfinishParcel,
      child: Consumer<ParcelViewModel>(
        builder: (context, parcelModel, _) {
          return Stack(
            children: [
              (parcelModel.loading || unfinishParcelList == null)
                  ? cartShimmerView(context)
                  : (parcelModel == null ||
                          unfinishParcelList == null ||
                          unfinishParcelList.length < 1)
                      ? noTransactionData(
                          widget.keyThree, widget.isShowcase, widget.isHeader)
                      : Column(
                          children: [
                            transactionHeader(
                                widget.key, widget.isShowcase, widget.isHeader),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 0),
                                    )
                                  ]),
                              padding: const EdgeInsets.only(top: 4.0),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                shrinkWrap: true,
                                itemCount: (unfinishParcelList.length > 3)
                                    ? 3
                                    : unfinishParcelList.length,
                                itemBuilder: (context, position) {
                                  UnfinishParcelData unfinishParcelData =
                                      unfinishParcelList[position];
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 8.0, 12.0, 3.0),
                                    child: TransactionItem(
                                      type: 'unfinish_parcel',
                                      unfinishParcel: unfinishParcelData,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ],
          );
        },
      ),
    );
  }

  Widget homePopsafeWidget() {
    return RefreshIndicator(
      onRefresh: _refreshOnGoingPopsafe,
      child: Consumer<PopsafeViewModel>(
        builder: (context, popsafeModel, _) {
          return Stack(
            children: [
              (popsafeModel.loading)
                  ? cartShimmerView(context)
                  : (popsafeModel == null ||
                          myListPopsafeHome == null ||
                          myListPopsafeHome.length < 1)
                      ? noTransactionData(
                          widget.keyThree, widget.isShowcase, widget.isHeader)
                      : Column(
                          children: [
                            transactionHeader(
                                widget.key, widget.isShowcase, widget.isHeader),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 0),
                                    )
                                  ]),
                              padding: const EdgeInsets.only(top: 4.0),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                shrinkWrap: true,
                                itemCount: (myListPopsafeHome.length > 3)
                                    ? 3
                                    : myListPopsafeHome.length,
                                itemBuilder: (context, position) {
                                  PopsafeHistoryData popsafeHistoryData =
                                      myListPopsafeHome[position];
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 8.0, 12.0, 3.0),
                                    child: TransactionItem(
                                      type: 'popsafe',
                                      popsafe: popsafeHistoryData,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ],
          );
        },
      ),
    );
  }

  Widget homePopcenterWidget() {
    return RefreshIndicator(
      onRefresh: _refreshPopCenter,
      child: Consumer<PopcenterViewModel>(
        builder: (context, popcenterModel, _) {
          return Stack(
            children: [
              (popcenterModel.loading)
                  ? cartShimmerView(context)
                  : (popcenterModel == null ||
                          myListPaginationPopcenter == null ||
                          myListPaginationPopcenter.length < 1)
                      ? noTransactionData(
                          widget.keyThree, widget.isShowcase, widget.isHeader)
                      : Column(
                          children: [
                            transactionHeader(
                                widget.key, widget.isShowcase, widget.isHeader),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 0),
                                    )
                                  ]),
                              padding: const EdgeInsets.only(top: 4.0),
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  shrinkWrap: true,
                                  itemCount:
                                      (myListPaginationPopcenter.length > 3)
                                          ? 3
                                          : myListPaginationPopcenter.length,
                                  itemBuilder: (context, position) {
                                    PopcenterHistoryData item =
                                        myListPaginationPopcenter[position];
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12.0, 8.0, 12.0, 3.0),
                                      child: TransactionItem(
                                        type: 'popcenter',
                                        popcenter: item,
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        )
            ],
          );
        },
      ),
    );
  }

  Widget noTransactionData(GlobalKey key, bool isShowcase, bool isHeader) {
    return RefreshIndicator(
      onRefresh: () {
        if (widget.isHome == true) {
          if (checkedIndex == 0) {
            return _refreshUnfinishParcel();
          } else {
            return _refreshOnGoingPopsafe();
          }
        } else {
          if (checkedIndex == 0) {
            return _refresh();
          } else {
            return _refreshPopsafe();
          }
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            isHeader
                ? transactionHeader(key, isShowcase, isHeader)
                : Container(),
            SizedBox(height: 26),
            InkWell(
              onTap: () {
                if (userData.isGuest == true || userData == null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
              child: Container(
                width: 100.0.w,
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: PopboxColor.orangeFFFAE7,
                ),
                padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign,
                      color: PopboxColor.orangeFF6500,
                    ),
                    SizedBox(width: 7),
                    CustomWidget().textRegular(
                        userData.isGuest
                            ? AppLocalizations.of(context).translate(
                                LanguageKeys.pleaseLoginToViewTransactions)
                            : AppLocalizations.of(context)
                                .translate(LanguageKeys.noTransactionsYet),
                        PopboxColor.mdBlack1000,
                        12.0,
                        TextAlign.left),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionHeader(
    GlobalKey key,
    bool isShowcase,
    bool isHeader,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: isHeader
              ? const EdgeInsets.fromLTRB(20.0, 24.0, 16.0, 10.0)
              : const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: isHeader
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.yourTransaction),
                      PopboxColor.popboxBlackGrey,
                      16,
                      TextAlign.left,
                    ),
                    (userData.isGuest)
                        ? Container()
                        : InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TransactionNewPage(
                                    isHeader: false,
                                    isHome: false,
                                    isSearchable: true,
                                    isShowcase: false,
                                    keyThree: null,
                                    from: "home",
                                  ),
                                ),
                              );
                            },
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.seeAll),
                              PopboxColor.blue477FFF,
                              12,
                              TextAlign.left,
                            ),
                          ),
                  ],
                )
              : Container(),
        ),
        widget.from == "parcel"
            ? InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WebviewPage(
                        reason: "parcel",
                        appbarTitle: AppLocalizations.of(context)
                            .translate(LanguageKeys.take),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
                  width: 100.0.w,
                  height: 75,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xffFF7971),
                        Color(0xffFF5469),
                        Color(0xffFF3159),
                      ],
                      tileMode: TileMode.mirror,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget().textBoldPlus(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.parcelHelpTitle),
                              Colors.white,
                              15,
                              TextAlign.left),
                          CustomWidget().textLight(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.parcelHelpSubtitle),
                            Colors.white,
                            12,
                            TextAlign.left,
                          ),
                        ],
                      ),
                      Image.asset(
                          "assets/images/ic_help_ilustration_popsafe.png"),
                    ],
                  ),
                ),
              )
            : Container(),
        widget.isSearchable
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12.0, bottom: 20),
                child: CustomWidget().textGreyBorderRegularSearchTransaction(
                    (value) => _runSearch(value),
                    AppLocalizations.of(context).translate(LanguageKeys.search),
                    PopboxColor.mdGrey900,
                    12),
              )
            : Container(),
        (widget.from != "parcel" && widget.isHome)
            ? isShowcase && userData.isGuest == false
                ? CustomWidget().showcaseView(
                    key: key,
                    child: serviceItem(),
                    context: context,
                    isLast: false,
                    content: AppLocalizations.of(context)
                        .translate(LanguageKeys.showcaseTransactionContent),
                    showHeader: false,
                  )
                : serviceItem()
            : Container(),
        (widget.from != "parcel" && widget.isHome == false)
            ? serviceItem()
            : Container()
      ],
    );
  }

  Widget filterTransaction() {
    return Container(
      margin: const EdgeInsets.only(left: 23),
      height: 33.0,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              showPopUpFilter(context: context);
            },
            child: LocationFilterItem(
                isIcon: true,
                service: "Filter",
                color: PopboxColor.popboxGrey575757),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listOfFilterUser.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, index) {
                String item = listOfFilterUser[index].nameTranslated;
                return InkWell(
                    onTap: () {
                      print("on TAP => " + item);
                    },
                    child: LocationFilterItem(
                      isIcon: false,
                      service: item,
                      color: PopboxColor.popboxRed,
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void showPopUpFilter({context}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Stack(
                children: [
                  //TITLE
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Icon(Icons.arrow_back),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    CustomWidget().textBold(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.filter),
                                      PopboxColor.mdBlack1000,
                                      12.0.sp,
                                      TextAlign.center,
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    setstateBuilder(() {
                                      if (widget.isHome == false) {
                                        if (checkedIndex == 0) {
                                          parcelCheckedOverdue = false;
                                          parcelCheckedComplete = false;
                                          parcelCheckedInstore = false;
                                          parcelCheckedCustomertaken = false;
                                          parcelCheckedCouriertaken = false;
                                          parcelCheckedOperatortaken = false;
                                          parcelCheckedCanceled = false;
                                          flagLastmile = false;
                                          flagPopsafe = false;
                                          flagFnb = false;
                                          _parcelFilterOverdue = null;
                                          _parcelFilterComplete = null;
                                          _parcelFilterInstore = null;
                                          _parcelFilterCustomertaken = null;
                                          _parcelFilterCouriertaken = null;
                                          _parcelFilterOperatortaken = null;
                                          _parcelFilterCanceled = null;
                                          _flagFilterLastmile = null;
                                          _flagFilterPopsafe = null;
                                          _flagFilterFnb = null;
                                        } else if (checkedIndex == 1) {
                                          popsafeCheckedCreated = false;
                                          popsafeCheckedInstore = false;
                                          popsafeCheckedOverdue = false;
                                          popsafeCheckedExpired = false;
                                          popsafeCheckedCancel = false;
                                          popsafeCheckedCustomertaken = false;
                                          _popsafeFilterCreated = null;
                                          _popsafeFilterInstore = null;
                                          _popsafeFilterOverdue = null;
                                          _popsafeFilterCustomertaken = null;
                                          _popsafeFilterExpired = null;
                                          _popsafeFilterCancel = null;
                                        } else {
                                          popcenterCheckedInbound = false;
                                          popcenterCheckedOutbound = false;
                                          popcenterCheckedOutboundCourier =
                                              false;
                                          popcenterCheckedOutboundOperator =
                                              false;
                                          popcenterCheckedDestroy = false;
                                          popcenterCheckedInboundLocker = false;
                                          _popcenterFilterInbound = null;
                                          _popcenterFilterOutbound = null;
                                          _popcenterFilterOutboundCourier =
                                              null;
                                          _popcenterFilterOutboundOperator =
                                              null;
                                          _popcenterFilterDestroy = null;
                                          _popcenterFilterInboundLocker = null;
                                        }
                                      }
                                    });
                                    setState(() {
                                      listOfFilterUser = [];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 30),
                                    child: CustomWidget().textRegular(
                                      "Reset Filter",
                                      PopboxColor.blue477FFF,
                                      12,
                                      TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Divider(
                        height: 1.0,
                        color: Colors.grey,
                      ),
                      //CONTAIN FILTER
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: ListView(
                          children: [
                            if (checkedIndex == 0)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 14, top: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CustomWidget().textBoldPlus(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.status),
                                    PopboxColor.mdBlack1000,
                                    12.0.sp,
                                    TextAlign.center,
                                  ),
                                ),
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.overdue),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: parcelCheckedOverdue,
                                onChanged: !isParcelFilterbyStatus
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          parcelCheckedOverdue = newValue;

                                          if (mounted) {
                                            setState(() {
                                              if (parcelCheckedOverdue ==
                                                  false) {
                                                isParcelFilterbyType = true;
                                                _parcelFilterOverdue = "";
                                                listOfFilterUser.removeWhere(
                                                  (element) =>
                                                      element.nameTranslated ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              LanguageKeys
                                                                  .overdue),
                                                );
                                              } else {
                                                isParcelFilterbyType = false;
                                                _parcelFilterOverdue =
                                                    "OVERDUE";
                                                listOfFilterUser
                                                    .add(ListFilterUser(
                                                  id: 1,
                                                  name: _parcelFilterOverdue,
                                                  nameTranslated:
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                    LanguageKeys.overdue,
                                                  ),
                                                ));
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                            .translate(LanguageKeys.instore)[0]
                                            .toUpperCase() +
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.instore)
                                            .substring(1)
                                            .toLowerCase(),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: parcelCheckedInstore,
                                onChanged: !isParcelFilterbyStatus
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          parcelCheckedInstore = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (parcelCheckedInstore ==
                                                  false) {
                                                isParcelFilterbyType = true;
                                                _parcelFilterInstore = "";
                                                listOfFilterUser.removeWhere(
                                                  (element) =>
                                                      element.nameTranslated ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              LanguageKeys
                                                                  .instore),
                                                );
                                              } else {
                                                isParcelFilterbyType = false;
                                                _parcelFilterInstore =
                                                    "IN_STORE";
                                                listOfFilterUser
                                                    .add(ListFilterUser(
                                                  id: 3,
                                                  name: _parcelFilterInstore,
                                                  nameTranslated:
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                    LanguageKeys.instore,
                                                  ),
                                                ));
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.customerTaken),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: parcelCheckedCustomertaken,
                                onChanged: !isParcelFilterbyStatus
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          parcelCheckedCustomertaken = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (parcelCheckedCustomertaken ==
                                                  false) {
                                                isParcelFilterbyType = true;
                                                _parcelFilterCustomertaken = "";
                                                listOfFilterUser.removeWhere(
                                                  (element) =>
                                                      element.nameTranslated ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(LanguageKeys
                                                              .customerTaken),
                                                );
                                              } else {
                                                isParcelFilterbyType = false;
                                                _parcelFilterCustomertaken =
                                                    "CUSTOMER_TAKEN";
                                                listOfFilterUser
                                                    .add(ListFilterUser(
                                                  id: 4,
                                                  name:
                                                      _parcelFilterCustomertaken,
                                                  nameTranslated:
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                    LanguageKeys.customerTaken,
                                                  ),
                                                ));
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.courierTaken),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: parcelCheckedCouriertaken,
                                onChanged: !isParcelFilterbyStatus
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          parcelCheckedCouriertaken = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (parcelCheckedCouriertaken ==
                                                  false) {
                                                isParcelFilterbyType = true;
                                                _parcelFilterCouriertaken = "";
                                                listOfFilterUser.removeWhere(
                                                  (element) =>
                                                      element.nameTranslated ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(LanguageKeys
                                                              .courierTaken),
                                                );
                                              } else {
                                                isParcelFilterbyType = false;
                                                _parcelFilterCouriertaken =
                                                    "COURIER_TAKEN";
                                                listOfFilterUser
                                                    .add(ListFilterUser(
                                                  id: 5,
                                                  name:
                                                      _parcelFilterCouriertaken,
                                                  nameTranslated:
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                    LanguageKeys.courierTaken,
                                                  ),
                                                ));
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.operatorTaken),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: parcelCheckedOperatortaken,
                                onChanged: !isParcelFilterbyStatus
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          parcelCheckedOperatortaken = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (parcelCheckedOperatortaken ==
                                                  false) {
                                                isParcelFilterbyType = true;
                                                _parcelFilterOperatortaken = "";
                                                listOfFilterUser.removeWhere(
                                                  (element) =>
                                                      element.nameTranslated ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(LanguageKeys
                                                              .operatorTaken),
                                                );
                                              } else {
                                                isParcelFilterbyType = false;
                                                _parcelFilterOperatortaken =
                                                    "OPERATOR_TAKEN";
                                                listOfFilterUser
                                                    .add(ListFilterUser(
                                                  id: 6,
                                                  name:
                                                      _parcelFilterOperatortaken,
                                                  nameTranslated:
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                    LanguageKeys.operatorTaken,
                                                  ),
                                                ));
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 14, top: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CustomWidget().textBoldPlus(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.trasaction),
                                    PopboxColor.mdBlack1000,
                                    12.0.sp,
                                    TextAlign.center,
                                  ),
                                ),
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.lastmile),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: flagLastmile,
                                onChanged: !isParcelFilterbyType
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          flagLastmile = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (flagLastmile == false) {
                                                isParcelFilterbyStatus = true;
                                                _flagFilterLastmile = "";
                                                listOfFilterFlag.removeWhere(
                                                    (element) =>
                                                        element == "lastmile");
                                              } else {
                                                isParcelFilterbyStatus = false;
                                                _flagFilterLastmile =
                                                    "lastmile";
                                                listOfFilterFlag
                                                    .add(_flagFilterLastmile);
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.popsafe),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: flagPopsafe,
                                onChanged: !isParcelFilterbyType
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          flagPopsafe = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (flagPopsafe == false) {
                                                isParcelFilterbyStatus = true;
                                                _flagFilterPopsafe = "";
                                                listOfFilterFlag.removeWhere(
                                                    (element) =>
                                                        element == "popsafe");
                                              } else {
                                                isParcelFilterbyStatus = false;
                                                _flagFilterPopsafe = "popsafe";
                                                listOfFilterFlag
                                                    .add(_flagFilterPopsafe);
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 0)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.fnb),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: flagFnb,
                                onChanged: !isParcelFilterbyType
                                    ? null
                                    : (newValue) {
                                        setState(() {
                                          flagFnb = newValue;
                                          if (mounted) {
                                            setState(() {
                                              if (flagFnb == false) {
                                                isParcelFilterbyStatus = true;
                                                _flagFilterFnb = "";
                                                listOfFilterFlag.removeWhere(
                                                    (element) =>
                                                        element == "fnb");
                                              } else {
                                                isParcelFilterbyStatus = false;
                                                _flagFilterFnb = "fnb";
                                                listOfFilterFlag
                                                    .add(_flagFilterFnb);
                                              }
                                            });
                                            setstateBuilder(() {});
                                          }
                                        });
                                      },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 1)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.orderCreated),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popsafeCheckedCreated,
                                onChanged: (newValue) {
                                  setState(() {
                                    popsafeCheckedCreated = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popsafeCheckedCreated == false) {
                                          _popsafeFilterCreated = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .orderCreated),
                                          );
                                        } else {
                                          _popsafeFilterCreated = "CREATED";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 7,
                                            name: _popsafeFilterCreated,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.orderCreated,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 1)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                            .translate(LanguageKeys.instore)[0]
                                            .toUpperCase() +
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.instore)
                                            .substring(1)
                                            .toLowerCase(),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popsafeCheckedInstore,
                                onChanged: (newValue) {
                                  setState(() {
                                    popsafeCheckedInstore = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popsafeCheckedInstore == false) {
                                          _popsafeFilterInstore = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.instore),
                                          );
                                        } else {
                                          _popsafeFilterInstore = "IN_STORE";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 8,
                                            name: _popsafeFilterInstore,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.instore,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 1)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.overdue),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popsafeCheckedOverdue,
                                onChanged: (newValue) {
                                  setState(() {
                                    popsafeCheckedOverdue = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popsafeCheckedOverdue == false) {
                                          _popsafeFilterOverdue = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.overdue),
                                          );
                                        } else {
                                          _popsafeFilterOverdue = "OVERDUE";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 9,
                                            name: _popsafeFilterOverdue,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.overdue,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 1)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.customerTaken),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popsafeCheckedCustomertaken,
                                onChanged: (newValue) {
                                  setState(() {
                                    popsafeCheckedCustomertaken = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popsafeCheckedCustomertaken ==
                                            false) {
                                          _popsafeFilterCustomertaken = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .customerTaken),
                                          );
                                        } else {
                                          _popsafeFilterCustomertaken =
                                              "CUSTOMER_TAKEN";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 10,
                                            name: _popsafeFilterCustomertaken,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.customerTaken,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.inboundPopcenter),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,

                                value: popcenterCheckedInbound,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedInbound = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedInbound == false) {
                                          _popcenterFilterInbound = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .inboundPopcenter),
                                          );
                                        } else {
                                          _popcenterFilterInbound =
                                              "INBOUND_POPCENTER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 11,
                                            name: _popcenterFilterInbound,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.inboundPopcenter,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.outboundPopcenter),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popcenterCheckedOutbound,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedOutbound = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedOutbound == false) {
                                          _popcenterFilterOutbound = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .outboundPopcenter),
                                          );
                                        } else {
                                          _popcenterFilterOutbound =
                                              "OUTBOUND_POPCENTER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 12,
                                            name: _popcenterFilterOutbound,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.outboundPopcenter,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.outboundCourierPopcenter),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popcenterCheckedOutboundCourier,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedOutboundCourier = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedOutboundCourier ==
                                            false) {
                                          _popcenterFilterOutboundCourier = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .outboundCourierPopcenter),
                                          );
                                        } else {
                                          _popcenterFilterOutboundCourier =
                                              "OUTBOUND_COURIER_POPCENTER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 13,
                                            name:
                                                _popcenterFilterOutboundCourier,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys
                                                  .outboundCourierPopcenter,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.outboundOperatorPopcenter),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popcenterCheckedOutboundOperator,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedOutboundOperator = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedOutboundOperator ==
                                            false) {
                                          _popcenterFilterOutboundOperator = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .outboundOperatorPopcenter),
                                          );
                                        } else {
                                          _popcenterFilterOutboundOperator =
                                              "OUTBOUND_OPERATOR_POPCENTER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 14,
                                            name:
                                                _popcenterFilterOutboundOperator,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys
                                                  .outboundOperatorPopcenter,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.destroyPopcenter),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popcenterCheckedDestroy,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedDestroy = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedDestroy == false) {
                                          _popcenterFilterDestroy = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .destroyPopcenter),
                                          );
                                        } else {
                                          _popcenterFilterDestroy =
                                              "DESTROY_POPCENTER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 15,
                                            name: _popcenterFilterDestroy,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys.destroyPopcenter,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            if (checkedIndex == 2)
                              CheckboxListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.inboundPopcenterLocker),
                                    Colors.black,
                                    14,
                                    TextAlign.left),
                                activeColor: PopboxColor.red,
                                value: popcenterCheckedInboundLocker,
                                onChanged: (newValue) {
                                  setState(() {
                                    popcenterCheckedInboundLocker = newValue;
                                    if (mounted) {
                                      setState(() {
                                        if (popcenterCheckedInboundLocker ==
                                            false) {
                                          _popcenterFilterInboundLocker = "";
                                          listOfFilterUser.removeWhere(
                                            (element) =>
                                                element.nameTranslated ==
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .inboundPopcenterLocker),
                                          );
                                        } else {
                                          _popcenterFilterInboundLocker =
                                              "INBOUND_POPCENTER_LOCKER";
                                          listOfFilterUser.add(ListFilterUser(
                                            id: 16,
                                            name: _popcenterFilterInboundLocker,
                                            nameTranslated:
                                                AppLocalizations.of(context)
                                                    .translate(
                                              LanguageKeys
                                                  .inboundPopcenterLocker,
                                            ),
                                          ));
                                        }
                                      });
                                      setstateBuilder(() {});
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, //  <-- leading Checkbox
                              ),
                            SizedBox(height: 20.0.h),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          if (listOfFilterUser.isEmpty &&
                              listOfFilterFlag.isEmpty) {
                            ///PARCEL
                            if (checkedIndex == 0) {
                              isFilterParcel = false;
                              setState(() {
                                parcelHistoryList = [];
                                myListPagination = [];
                                pagePagination = 1;
                                currentMaxPagination = 10;
                                //PARCEL
                                ParcelForYouHistoryPayload
                                    parcelForYouHistoryPayload =
                                    new ParcelForYouHistoryPayload();
                                parcelForYouHistoryPayload.token =
                                    GlobalVar.API_TOKEN;
                                parcelForYouHistoryPayload.page =
                                    pagePagination.toString();
                                parcelForYouHistoryPayload.isComplete = "all";

                                parcelForYouHistoryPayload.sessionId =
                                    userData.sessionId;
                                parcelForYouHistoryPayload.status = "";
                                parcelModel.getParcelHistoryList(
                                  parcelForYouHistoryPayload,
                                  context,
                                  onSuccess: (response) {
                                    //debug rafi
                                    if (!mounted) return;
                                    //
                                    setState(() {
                                      parcelHistoryList = [];
                                      if (response != null &&
                                          response.data != null) {
                                        parcelHistoryList = response.data;
                                        totalPagePagination =
                                            response.totalpage;
                                        myListPagination = response.data;
                                        _loadMoreNewPage();
                                      }
                                    });
                                  },
                                  onError: (response) {
                                    setState(() {
                                      parcelHistoryList = [];
                                    });
                                  },
                                );
                              });
                            } else if (checkedIndex == 1) {
                              isFilterPopsafe = false;
                              setState(() {
                                popsafeHistoryList = [];
                                myListPaginationPopsafe = [];
                                pagePaginationPopsafe = 1;
                                currentMaxPaginationPopsafe = 10;
                                //Popsafe
                                PopsafeHistoryPayload popsafeHistoryPayload =
                                    new PopsafeHistoryPayload();

                                popsafeHistoryPayload.token =
                                    GlobalVar.API_TOKEN;
                                popsafeHistoryPayload.page =
                                    pagePaginationPopsafe;
                                popsafeHistoryPayload.sessionId =
                                    userData.sessionId;
                                popsafeHistoryPayload.status = "all";

                                popsafeModel.getPopsafeHistoryList(
                                  popsafeHistoryPayload,
                                  context,
                                  onSuccess: (response) {
                                    setState(() {
                                      popsafeHistoryList = [];
                                      if (response != null &&
                                          response.data != null) {
                                        popsafeHistoryList = response.data;
                                        totalPagePaginationPopsafe =
                                            response.totalpage;
                                        myListPopsafeHome = response.data;

                                        myListPaginationPopsafe = response.data;

                                        _loadMoreNewPagePopsafe();
                                      }
                                    });
                                  },
                                  onError: (response) {
                                    setState(() {
                                      popsafeHistoryList = [];
                                    });
                                  },
                                );
                              });
                            } else {
                              isFilterPopcenter = false;
                              setState(() {
                                popcenterList = [];
                                myListPaginationPopcenter = [];
                                pagePaginationPopcenter = 1;
                                currentMaxPaginationPopcenter = 10;
                                PopcenterListPayload popcenterListPayload =
                                    new PopcenterListPayload();

                                popcenterListPayload.authorization =
                                    GlobalVar.API_TOKEN_POPCENTER;
                                popcenterListPayload.page =
                                    pagePaginationPopcenter;
                                popcenterListPayload.phoneNumber =
                                    userData.phone;
                                popcenterListPayload.timeInbound = null;
                                popcenterListPayload.status = [];
                                popcenterModel.popcenterList(
                                  popcenterListPayload,
                                  context,
                                  onSuccess: (response) {
                                    setState(() {
                                      popcenterList = [];
                                      popcenterList.clear();
                                      if (response != null &&
                                          response.data.data != null) {
                                        popcenterList = response.data.data;
                                        totalPagePaginationPopcenter = response
                                            .data.paginate.totalPaginate;
                                        myListPaginationPopcenter =
                                            response.data.data;
                                        _loadMoreNewPagePopcenter();
                                      }
                                    });
                                  },
                                  onError: (response) {
                                    setState(() {
                                      popcenterList = [];
                                    });
                                  },
                                );
                              });
                            }
                          } else {
                            if (checkedIndex == 0) {
                              setState(() {
                                parcelHistoryList = [];
                                myListPagination = [];
                                parcelHistoryList.clear();
                                myListPagination.clear();
                                dummyparcelHistoryList = [];
                                dummyparcelHistoryList.clear();
                                isFilterParcel = true;

                                if (listOfFilterUser.isNotEmpty) {
                                  for (var item in listAllParcelForFilter) {
                                    for (int i = 0;
                                        i < listOfFilterUser.length;
                                        i++) {
                                      if (item.status
                                          .contains(listOfFilterUser[i].name)) {
                                        dummyparcelHistoryList.add(item);
                                      }
                                    }
                                  }
                                } else if (listOfFilterFlag.isNotEmpty) {
                                  //else bool flag
                                  for (var item in listAllParcelForFilter) {
                                    for (int i = 0;
                                        i < listOfFilterFlag.length;
                                        i++) {
                                      if (item.categoryPackage
                                          .contains(listOfFilterFlag[i])) {
                                        dummyparcelHistoryList.add(item);
                                      }
                                    }
                                  }
                                } else {}

                                parcelHistoryList = dummyparcelHistoryList;
                                myListPagination = dummyparcelHistoryList;
                              });
                            } else if (checkedIndex == 1) {
                              setState(() {
                                isFilterPopsafe = true;
                                popsafeHistoryList = [];
                                myListPaginationPopsafe = [];
                                popsafeHistoryList.clear();
                                myListPaginationPopsafe.clear();
                                dummypopsafeHistoryList = [];
                                dummypopsafeHistoryList.clear();

                                for (var item in listAllPopsafeForFilter) {
                                  for (int i = 0;
                                      i < listOfFilterUser.length;
                                      i++) {
                                    if (item.status
                                        .contains(listOfFilterUser[i].name)) {
                                      dummypopsafeHistoryList.add(item);
                                    }
                                  }
                                }
                                popsafeHistoryList = dummypopsafeHistoryList;
                                myListPaginationPopsafe =
                                    dummypopsafeHistoryList;
                              });
                            } else {
                              //POPCENTER
                              setState(() {
                                isFilterPopcenter = true;
                                popcenterList = [];
                                myListPaginationPopcenter = [];
                                popcenterList.clear();
                                myListPaginationPopcenter.clear();
                                dummypopcenterHistoryList = [];
                                dummypopcenterHistoryList.clear();

                                for (var item in listAllPopcenterForFilter) {
                                  for (int i = 0;
                                      i < listOfFilterUser.length;
                                      i++) {
                                    if (item.status
                                        .contains(listOfFilterUser[i].name)) {
                                      dummypopcenterHistoryList.add(item);
                                    }
                                  }
                                }
                                popcenterList = dummypopcenterHistoryList;
                                myListPaginationPopcenter =
                                    dummypopcenterHistoryList;
                              });
                            }
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 16),
                          decoration: BoxDecoration(
                            color: PopboxColor.popboxGreyPopsafe,
                          ),
                          child: CustomWidget().customColorButton(
                            context,
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.show),
                            PopboxColor.red,
                            PopboxColor.mdWhite1000,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  Widget serviceItem() {
    return Container(
      height: 35.0,
      margin: const EdgeInsets.only(left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount:
            StaticData().getPopboxService(context, isHistory: true).length,
        itemBuilder: (BuildContext context, int index) {
          PopboxService service =
              StaticData().getPopboxService(context, isHistory: true)[index];

          return Container(
            padding: const EdgeInsets.only(right: 10),
            child: serviceTypeItem(
              index,
              service.title,
            ),
          );
        },
      ),
    );
  }

  Widget serviceTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            checkedIndex = index;
            listOfFilterUser.clear();
          });
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 10.0,
            minWidth: 10.0,
            maxWidth: 100.0.w,
            maxHeight: 100.0.h),
        child: RawMaterialButton(
          fillColor: checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          splashColor:
              checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          child: CustomWidget().textRegular(
            title,
            checked ? PopboxColor.mdWhite1000 : PopboxColor.mdGrey700,
            12,
            TextAlign.center,
          ),
          onPressed: null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey350,
              )),
        ),
      ),
    );
  }

  void _runSearch(String inputKeyword) {
    isSearch = true;
    isSearchPopsafe = true;
    isSearchPopcenter = true;
    List results;
    if (inputKeyword.isEmpty) {
      isSearch = false;
      isSearchPopsafe = false;
      isSearchPopcenter = false;
      if (checkedIndex == 0) {
        results = parcelHistoryList;
      } else if (checkedIndex == 1) {
        results = popsafeHistoryList;
      } else {
        results = popcenterList;
      }
    } else {
      if (checkedIndex == 0) {
        results = parcelHistoryList
            .where((element) => element.orderNumber
                .toLowerCase()
                .contains(inputKeyword.toLowerCase()))
            .toList();
      } else if (checkedIndex == 1) {
        results = popsafeHistoryList
            .where((element) => element.invoiceCode
                .toLowerCase()
                .contains(inputKeyword.toLowerCase()))
            .toList();
      } else {
        results = popcenterList
            .where((element) => element.awbNumber
                .toLowerCase()
                .contains(inputKeyword.toLowerCase()))
            .toList();
      }
    }
    setState(() {
      if (checkedIndex == 0) {
        myListPagination = results;
      } else if (checkedIndex == 1) {
        myListPaginationPopsafe = results;
      } else {
        myListPaginationPopcenter = results;
      }
    });
  }

  Future<void> _refresh() async {
    pagePagination = 1;
    currentMaxPagination = 10;
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    ParcelForYouHistoryPayload parcelForYouHistoryPayload =
        new ParcelForYouHistoryPayload();
    parcelForYouHistoryPayload.token = GlobalVar.API_TOKEN;
    parcelForYouHistoryPayload.page = pagePagination.toString();
    parcelForYouHistoryPayload.isComplete = "all";

    parcelForYouHistoryPayload.sessionId = userData.sessionId;
    parcelForYouHistoryPayload.status = "";
    await parcelModel.getParcelHistoryList(
      parcelForYouHistoryPayload,
      context,
      onSuccess: (response) {
        //debug rafi
        if (!mounted) return;
        //
        setState(() {
          isFilterParcel = false;
          parcelHistoryList = [];
          myListPagination = [];
          listAllParcelForFilter = [];
          myListPagination.length = 0;
          myListPagination.clear();
          parcelHistoryList.clear();
          listAllParcelForFilter.clear();
          listOfFilterUser = [];

          parcelCheckedOverdue = false;
          parcelCheckedComplete = false;
          parcelCheckedInstore = false;
          parcelCheckedCustomertaken = false;
          parcelCheckedCouriertaken = false;
          parcelCheckedOperatortaken = false;
          parcelCheckedCanceled = false;
          _parcelFilterOverdue = null;
          _parcelFilterComplete = null;
          _parcelFilterInstore = null;
          _parcelFilterCustomertaken = null;
          _parcelFilterCouriertaken = null;
          _parcelFilterOperatortaken = null;
          _parcelFilterCanceled = null;

          if (response != null && response.data != null) {
            parcelHistoryList = response.data;
            totalPagePagination = response.totalpage;
            myListPagination = response.data;
            listAllParcelForFilter = response.data;
            _loadMoreNewPage();
          }
        });
      },
      onError: (response) {
        setState(() {
          parcelHistoryList = [];
        });
      },
    );
  }

  Future<void> _refreshPopsafe() async {
    pagePaginationPopsafe = 1;
    currentMaxPaginationPopsafe = 10;

    PopsafeHistoryPayload popsafeHistoryPayload = new PopsafeHistoryPayload();

    popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
    popsafeHistoryPayload.page = pagePaginationPopsafe;
    popsafeHistoryPayload.sessionId = userData.sessionId;
    popsafeHistoryPayload.status = "all";

    await popsafeModel.getPopsafeHistoryList(
      popsafeHistoryPayload,
      context,
      onSuccess: (response) {
        setState(() {
          isFilterPopsafe = false;
          listOfFilterUser = [];
          popsafeCheckedCreated = false;
          popsafeCheckedInstore = false;
          popsafeCheckedOverdue = false;
          popsafeCheckedExpired = false;
          popsafeCheckedCancel = false;
          popsafeCheckedCustomertaken = false;
          _popsafeFilterCreated = null;
          _popsafeFilterInstore = null;
          _popsafeFilterOverdue = null;
          _popsafeFilterCustomertaken = null;
          _popsafeFilterExpired = null;
          _popsafeFilterCancel = null;
          popsafeHistoryList = [];
          popsafeHistoryList.clear();
          listAllPopsafeForFilter = [];
          listAllPopsafeForFilter.clear();
          if (response != null && response.data != null) {
            popsafeHistoryList = response.data;
            totalPagePaginationPopsafe = response.totalpage;
            myListPopsafeHome = response.data;
            listAllPopsafeForFilter = response.data;

            myListPaginationPopsafe = response.data;

            _loadMoreNewPagePopsafe();
          }
        });
      },
      onError: (response) {
        setState(() {
          popsafeHistoryList = [];
        });
      },
    );
  }

  Future<void> _refreshPopCenter() async {
    pagePaginationPopcenter = 1;
    currentMaxPaginationPopcenter = 10;

    PopcenterListPayload popcenterListPayload = new PopcenterListPayload();

    popcenterListPayload.authorization = GlobalVar.API_TOKEN_POPCENTER;
    popcenterListPayload.page = pagePaginationPopcenter;
    popcenterListPayload.phoneNumber = userData.phone;
    popcenterListPayload.timeInbound = null;
    if (widget.isHome) {
      popcenterListPayload.status = [
        "INBOUND_POPCENTER",
        "INBOUND_POPCENTER_LOCKER"
      ];
    } else {
      popcenterListPayload.status = [];
    }

    await popcenterModel.popcenterList(
      popcenterListPayload,
      context,
      onSuccess: (response) {
        setState(() {
          popcenterCheckedInbound = false;
          popcenterCheckedOutbound = false;
          popcenterCheckedOutboundCourier = false;
          popcenterCheckedOutboundOperator = false;
          popcenterCheckedDestroy = false;
          popcenterCheckedInboundLocker = false;
          _popcenterFilterInbound = null;
          _popcenterFilterOutbound = null;
          _popcenterFilterOutboundCourier = null;
          _popcenterFilterOutboundOperator = null;
          _popcenterFilterDestroy = null;
          _popcenterFilterInboundLocker = null;
          popcenterList = [];
          popcenterList.clear();
          if (response != null && response.data.data != null) {
            popcenterList = response.data.data;
            totalPagePaginationPopcenter = response.data.paginate.totalPaginate;
            myListPaginationPopcenter = response.data.data;
            _loadMoreNewPagePopcenter();
          }
        });
      },
      onError: (response) {
        setState(() {
          popcenterList = [];
        });
      },
    );
  }

  Future<void> _refreshOnGoingPopsafe() async {
    print("Pull refresh => _refreshOnGoingPopsafe");
    await Future.delayed(Duration(seconds: 0, milliseconds: 50));
    myListPopsafeHome.length = 0;
    myListPopsafeHome.clear();
    setState(() {
      pagePaginationPopsafe = 1;
      _loadOnGoingPopsafe();
    });
  }

  Future<void> _refreshUnfinishParcel() async {
    print("Pull refresh => _refreshUnfinishparcel");
    await Future.delayed(Duration(seconds: 0, milliseconds: 10));
    unfinishParcelList.length = 0;
    unfinishParcelList.clear();
    setState(() {
      _loadUnfinishParcel();
    });
  }

  void _loadUnfinishParcel() async {
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);
    userData = await SharedPreferencesService().getUser();

    UnfinishParcelPayload unfinishParcelPayload = new UnfinishParcelPayload();
    unfinishParcelPayload.token = GlobalVar.API_TOKEN;
    unfinishParcelPayload.limit = 10;
    unfinishParcelPayload.sessionId = userData.sessionId;
    await parcelModel.unfinishParcelHistory(unfinishParcelPayload, context,
        onSuccess: (response) {
      if (mounted) {
        setState(() {
          unfinishParcelList = [];
          if (response != null && response.data != null) {
            unfinishParcelList = response.data;
          }
        });
      }
    }, onError: (response) {
      if (mounted) {
        setState(() {
          unfinishParcelList = [];
        });
      }
    });
  }

  void _loadOnGoingPopsafe() async {
    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);
    PopsafeHistoryPayload popsafeHistoryPayload = new PopsafeHistoryPayload();

    popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
    popsafeHistoryPayload.page = pagePaginationPopsafe;
    popsafeHistoryPayload.sessionId = userData.sessionId;
    if (widget.isHome) {
      popsafeHistoryPayload.status = "ongoing";
    } else {
      popsafeHistoryPayload.status = "all";
    }

    await popsafeModel.getPopsafeHistoryList(
      popsafeHistoryPayload,
      context,
      onSuccess: (response) {
        setState(() {
          myListPopsafeHome = [];
          if (response != null && response.data != null) {
            myListPopsafeHome = response.data;
          }
        });
      },
      onError: (response) {
        setState(() {
          myListPopsafeHome = [];
        });
      },
    );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 1500));
    loadMorePagination();
    return true;
  }

  void _loadMoreNewPage() async {
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);

    for (int i = 0; i <= totalPagePagination; i++) {
      print("======>>>>>>>>>>>>>>>>> _loadMoreNewPage index $i");
      pagePagination = pagePagination + 1;
      ParcelForYouHistoryPayload parcelForYouHistoryPayload =
          new ParcelForYouHistoryPayload();
      parcelForYouHistoryPayload.token = GlobalVar.API_TOKEN;
      parcelForYouHistoryPayload.page = pagePagination.toString();
      parcelForYouHistoryPayload.isComplete = "all";
      parcelForYouHistoryPayload.sessionId = userData.sessionId;
      parcelForYouHistoryPayload.status = "";
      await parcelModel.getParcelHistoryList(
        parcelForYouHistoryPayload,
        context,
        onSuccess: (response) {
          if (response != null && response.data != null) {
            parcelHistoryList = parcelHistoryList + response.data;
            listAllParcelForFilter = listAllParcelForFilter + response.data;
          }
        },
        onError: (response) {
          setState(() {
            parcelHistoryList = [];
          });
        },
      );
    }
  }

  void _loadCompleteParcel() async {
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);
    //PARCEL
    ParcelForYouHistoryPayload parcelForYouHistoryPayload =
        new ParcelForYouHistoryPayload();
    parcelForYouHistoryPayload.token = GlobalVar.API_TOKEN;
    parcelForYouHistoryPayload.page = pagePagination.toString();
    parcelForYouHistoryPayload.isComplete = "all";

    parcelForYouHistoryPayload.sessionId = userData.sessionId;
    parcelForYouHistoryPayload.status = "";
    await parcelModel.getParcelHistoryList(
      parcelForYouHistoryPayload,
      context,
      onSuccess: (response) {
        //debug rafi
        if (!mounted) return;
        //
        setState(() {
          parcelHistoryList = [];
          if (response != null && response.data != null) {
            parcelHistoryList = response.data;
            totalPagePagination = response.totalpage;
            myListPagination = response.data;
            _loadMoreNewPage();
          }
        });
      },
      onError: (response) {
        setState(() {
          parcelHistoryList = [];
        });
      },
    );
  }

  void _loadCompletePopsafe() async {
    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);
    PopsafeHistoryPayload popsafeHistoryPayload = new PopsafeHistoryPayload();

    popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
    popsafeHistoryPayload.page = pagePaginationPopsafe;
    popsafeHistoryPayload.sessionId = userData.sessionId;
    if (widget.isHome) {
      popsafeHistoryPayload.status = "ongoing";
    } else {
      popsafeHistoryPayload.status = "all";
    }

    await popsafeModel.getPopsafeHistoryList(
      popsafeHistoryPayload,
      context,
      onSuccess: (response) {
        setState(() {
          popsafeHistoryList = response.data;
          totalPagePaginationPopsafe = response.totalpage;
          myListPaginationPopsafe = response.data;
          _loadMoreNewPagePopsafe();
        });
      },
      onError: (response) {
        setState(() {
          myListPaginationPopsafe = [];
        });
      },
    );
  }

  Future<bool> _loadMorePopsafe() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 1500));
    loadMorePaginationPopsafe();
    return true;
  }

  Future<bool> _loadMorePopcenter() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 1500));
    loadMorePaginationPopcenter();
    return true;
  }

  void loadMorePagination() async {
    if ((parcelHistoryList.length - currentMaxPagination) >= 10) {
      for (int i = currentMaxPagination; i < currentMaxPagination + 10; i++) {
        myListPagination.add(parcelHistoryList[i]);
      }
      currentMaxPagination = currentMaxPagination + 10;
    } else if ((parcelHistoryList.length - currentMaxPagination) >= 5) {
      for (int i = currentMaxPagination; i < currentMaxPagination + 5; i++) {
        myListPagination.add(parcelHistoryList[i]);
      }
      currentMaxPagination = currentMaxPagination + 5;
    } else if ((parcelHistoryList.length - currentMaxPagination) >= 3) {
      for (int i = currentMaxPagination; i < currentMaxPagination + 3; i++) {
        myListPagination.add(parcelHistoryList[i]);
      }
      currentMaxPagination = currentMaxPagination + 3;
    } else if ((parcelHistoryList.length - currentMaxPagination) >= 2) {
      for (int i = currentMaxPagination; i < currentMaxPagination + 2; i++) {
        myListPagination.add(parcelHistoryList[i]);
      }
      currentMaxPagination = currentMaxPagination + 2;
    } else if ((parcelHistoryList.length - currentMaxPagination) >= 1) {
      for (int i = currentMaxPagination; i < currentMaxPagination + 1; i++) {
        myListPagination.add(parcelHistoryList[i]);
      }
      currentMaxPagination = currentMaxPagination + 1;
    }

    setState(() {});
  }

  void _loadMoreNewPagePopcenter() async {
    var popcenterModel =
        Provider.of<PopcenterViewModel>(context, listen: false);

    for (int i = 0; i <= totalPagePaginationPopcenter; i++) {
      pagePaginationPopcenter = pagePaginationPopcenter + 1;
      PopcenterListPayload popcenterListPayload = new PopcenterListPayload();

      popcenterListPayload.authorization = GlobalVar.API_TOKEN_POPCENTER;
      popcenterListPayload.page = pagePaginationPopcenter;
      popcenterListPayload.phoneNumber = userData.phone;
      popcenterListPayload.timeInbound = null;
      popcenterListPayload.status = [];

      await popcenterModel.popcenterList(
        popcenterListPayload,
        context,
        onSuccess: (response) {
          popcenterList = popcenterList + response.data.data;
          listAllPopcenterForFilter =
              listAllPopcenterForFilter + response.data.data;
        },
        onError: (response) {
          // setState(() {
          //   popcenterList = [];
          // });
        },
      );
    }
  }

  void _loadMoreNewPagePopsafe() async {
    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);

    for (int i = 0; i <= totalPagePaginationPopsafe; i++) {
      pagePaginationPopsafe = pagePaginationPopsafe + 1;
      PopsafeHistoryPayload popsafeHistoryPayload = new PopsafeHistoryPayload();
      popsafeHistoryPayload.token = GlobalVar.API_TOKEN;
      popsafeHistoryPayload.page = pagePaginationPopsafe;
      popsafeHistoryPayload.sessionId = userData.sessionId;
      if (widget.isHome) {
        popsafeHistoryPayload.status = "ongoing";
      } else {
        popsafeHistoryPayload.status = "all";
      }

      await popsafeModel.getPopsafeHistoryList(
        popsafeHistoryPayload,
        context,
        onSuccess: (response) {
          if (response != null && response.data != null) {
            // myListPaginationPopsafe = myListPaginationPopsafe + response.data;
            popsafeHistoryList = popsafeHistoryList + response.data;
            listAllPopsafeForFilter = listAllPopsafeForFilter + response.data;
          }
        },
        onError: (response) {
          setState(() {
            popsafeHistoryList = [];
          });
        },
      );
    }
  }

  void loadMorePaginationPopsafe() async {
    if ((popsafeHistoryList.length - currentMaxPaginationPopsafe) >= 10) {
      for (int i = currentMaxPaginationPopsafe;
          i < currentMaxPaginationPopsafe + 10;
          i++) {
        myListPaginationPopsafe.add(popsafeHistoryList[i]);
      }
      currentMaxPaginationPopsafe = currentMaxPaginationPopsafe + 10;
    } else if ((popsafeHistoryList.length - currentMaxPaginationPopsafe) >= 5) {
      for (int i = currentMaxPaginationPopsafe;
          i < currentMaxPaginationPopsafe + 5;
          i++) {
        myListPaginationPopsafe.add(popsafeHistoryList[i]);
      }
      currentMaxPaginationPopsafe = currentMaxPaginationPopsafe + 5;
    } else if ((popsafeHistoryList.length - currentMaxPaginationPopsafe) >= 3) {
      for (int i = currentMaxPaginationPopsafe;
          i < currentMaxPaginationPopsafe + 3;
          i++) {
        myListPaginationPopsafe.add(popsafeHistoryList[i]);
      }
      currentMaxPaginationPopsafe = currentMaxPaginationPopsafe + 3;
    } else if ((popsafeHistoryList.length - currentMaxPaginationPopsafe) >= 2) {
      for (int i = currentMaxPaginationPopsafe;
          i < currentMaxPaginationPopsafe + 2;
          i++) {
        myListPaginationPopsafe.add(popsafeHistoryList[i]);
      }
      currentMaxPaginationPopsafe = currentMaxPaginationPopsafe + 2;
    } else if ((popsafeHistoryList.length - currentMaxPaginationPopsafe) >= 1) {
      for (int i = currentMaxPaginationPopsafe;
          i < currentMaxPaginationPopsafe + 1;
          i++) {
        myListPaginationPopsafe.add(popsafeHistoryList[i]);
      }
      currentMaxPaginationPopsafe = currentMaxPaginationPopsafe + 1;
    }

    setState(() {});
  }

  void loadMorePaginationPopcenter() async {
    if ((popcenterList.length - currentMaxPaginationPopcenter) >= 10) {
      for (int i = currentMaxPaginationPopcenter;
          i < currentMaxPaginationPopcenter + 10;
          i++) {
        myListPaginationPopcenter.add(popcenterList[i]);
      }
      currentMaxPaginationPopcenter = currentMaxPaginationPopcenter + 10;
    } else if ((popcenterList.length - currentMaxPaginationPopcenter) >= 5) {
      for (int i = currentMaxPaginationPopcenter;
          i < currentMaxPaginationPopcenter + 5;
          i++) {
        myListPaginationPopcenter.add(popcenterList[i]);
      }
      currentMaxPaginationPopcenter = currentMaxPaginationPopcenter + 5;
    } else if ((popcenterList.length - currentMaxPaginationPopcenter) >= 3) {
      for (int i = currentMaxPaginationPopcenter;
          i < currentMaxPaginationPopcenter + 3;
          i++) {
        myListPaginationPopcenter.add(popcenterList[i]);
      }
      currentMaxPaginationPopcenter = currentMaxPaginationPopcenter + 3;
    } else if ((popcenterList.length - currentMaxPaginationPopcenter) >= 2) {
      for (int i = currentMaxPaginationPopcenter;
          i < currentMaxPaginationPopcenter + 2;
          i++) {
        myListPaginationPopcenter.add(popcenterList[i]);
      }
      currentMaxPaginationPopcenter = currentMaxPaginationPopcenter + 2;
    } else if ((popcenterList.length - currentMaxPaginationPopcenter) >= 1) {
      for (int i = currentMaxPaginationPopcenter;
          i < currentMaxPaginationPopcenter + 1;
          i++) {
        myListPaginationPopcenter.add(popcenterList[i]);
      }
      currentMaxPaginationPopcenter = currentMaxPaginationPopcenter + 1;
    }

    setState(() {});
  }
}
