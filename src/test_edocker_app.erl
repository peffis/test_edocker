-module(test_edocker_app).
-behaviour(application).

-compile([{parse_transform, lager_transform}]).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    boot(),
    test_edocker_sup:start_link().

stop(_State) ->
    ok.

boot() ->
    show_env(),

    Host = "127.0.0.1",
    Port = 8001,

    {ok, GunPid} = gun:open(Host, Port),
    {ok, _P} = gun:await_up(GunPid),
    NameSpace = os:getenv("EDOCKER_POD_NAMESPACE"),
    StreamRef = gun:get(GunPid, "/api/v1/namespaces/" ++ NameSpace ++ "/pods"),

    PodListDoc = case gun:await(GunPid, StreamRef) of
		     {response, fin, _Status, _Headers} ->
			 no_data;
		     {response, nofin, _Status, _Headers} ->
			 {ok, Body} = gun:await_body(GunPid, StreamRef),
			 jiffy:decode(Body, [return_maps])
		 end,
    
    ItemList = maps:get(<<"items">>, PodListDoc),
    MyPodName = list_to_binary(os:getenv("EDOCKER_POD_NAME")),

    ItemsNotMe = lists:filter(fun(I) ->
				      ItemName = maps:get(<<"name">>, maps:get(<<"metadata">>, I)),
				      ItemName /= MyPodName
			      end, ItemList),

    DiscoveredPodIPs = [maps:get(<<"podIP">>, maps:get(<<"status">>, P)) || P <- ItemsNotMe],

    MyName = os:getenv("EDOCKER_NAME"),
    [net_kernel:connect(list_to_atom(MyName ++ "@" ++ binary_to_list(IP))) || IP <- DiscoveredPodIPs],
    spawn(fun() -> monitor() end),
    ok.
     
monitor() ->
    timer:sleep(5000), 
    lager:info("known nodes: ~p", [nodes()]),
    monitor().


show_env() ->
    [lager:info("~s", [E]) || E <- os:getenv()].
    
