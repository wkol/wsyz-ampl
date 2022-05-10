set PRODUCENTS;   # producents
set WAREHOUSES;   # warehouses
set VEGETABLES;   # vegetables
set STORES;		  # stores

param T > 0;																	# number of weeks

param supply 		{PRODUCENTS,VEGETABLES} > 0;  								# amounts available at producents
param max_warehouse_capacity 	{WAREHOUSES} >= 0;       						# max capacity available at warehouses

param distance_to_warehouse {PRODUCENTS,WAREHOUSES} > 0;  						# distance from producent to warehouse
param distance_to_store 	{WAREHOUSES,STORES} > 0;  							# distance from warehouse to store

param weekly_sales_forecast {1..T, STORES, VEGETABLES} >= 0;  					# weekly sales forecast for vegetable and store

param store_warehouse_capacity 	{STORES} >= 0;       							# max store warehouse capacity available at the store

param km_cost > 0;																# cost to move 1 ton by 1km


var yearly_transport_to_warehouses {PRODUCENTS,WAREHOUSES,VEGETABLES} >= 0; 	# tons transported from producents to warehouses yearly
var weekly_transport_to_stores {1..T,WAREHOUSES,STORES,VEGETABLES} >= 0;				# tons transported from warehouses to stores weekly
            
# TODO czym sie rozni b) od c)? moze to trzeba zrobić inaczej, z jakimś stanem

minimize Total_Cost:
	sum {p in PRODUCENTS, w in WAREHOUSES, v in VEGETABLES}
   		distance_to_warehouse[p,w] * km_cost * yearly_transport_to_warehouses[p,w,v]
	+
	sum {w in WAREHOUSES, s in STORES, v in VEGETABLES, n in 1..T}
   		distance_to_store[w,s] * km_cost *  weekly_transport_to_stores[n,w,s,v];
    
# ograniczenie: transport do sklepów + należy zachować minimalne zapasy każdego z warzyw  np. 10% średniej sprzedaży w tygodniu
subject to Store_Weekly_Supply {v in VEGETABLES, s in STORES, n in 1..T}:
	sum {w in WAREHOUSES}
		weekly_transport_to_stores[n, w, s, v] = 1.1 * weekly_sales_forecast[n, s, v];
	
# ograniczenie: warehouse supply
subject to Warehouse_Supply {w in WAREHOUSES, v in VEGETABLES}:
	sum {p in PRODUCENTS} yearly_transport_to_warehouses[p, w, v] >= sum {s in STORES, n in 1..T} weekly_transport_to_stores[n, w, s, v];

# ograniczenie: producent supply
subject to Producent_Supply {p in PRODUCENTS, v in VEGETABLES}:
	sum {w in WAREHOUSES} yearly_transport_to_warehouses[p,w,v] <= supply[p, v];

# ograniczenie: max_capacity
subject to Warehouse_Max_Capacity {w in WAREHOUSES}:
	sum {p in PRODUCENTS, v in VEGETABLES} yearly_transport_to_warehouses[p,w,v] <= max_warehouse_capacity[w];

# ograniczenie: Zapas warzyw nie powinien przekroczyć pojemności przysklepowego magazynu
subject to Store_Warehouse_Max_Capacity {s in STORES, n in 1..T}:
	sum {w in WAREHOUSES, v in VEGETABLES} weekly_transport_to_stores[n, w, s, v] <= store_warehouse_capacity[s];