open Frenetic_Packet
open Frenetic_Network

open Merlin_FrontEnd
open Merlin_Types
open Merlin_Dictionaries


let test_solve input =
  let t = Printf.sprintf "./examples/%s/%s.dot" input input in
  let p =  Printf.sprintf "./examples/%s/%s.mln" input input in
  let s = "./test/solve_cases/" ^ input ^ ".exp" in

  let topo = parse_topo_file t in
  let ir =   policy_file_to_ir p in
  let flows = match ir with
    |Some ir -> solve ir topo
    | None -> [] in

  let sol = Merlin_Util.load_lines s in
  let expected = List.fold_left (fun acc line ->
    let expected_flows = Str.split (Str.regexp " ") line in
    List.fold_left (fun acc ef ->
      let data = Str.split (Str.regexp ":") ef in
      let h = List.nth data 0 in
      let t = List.nth data 1 in
      (h,(Int64.of_string t))::acc) acc expected_flows) [] sol in

  let got = List.fold_left (fun acc f ->
    let (_,forwards) = f in
    List.fold_left (fun acc fwd ->
      let node,devid = fwd.device in
      let label = Net.Topology.vertex_to_label topo fwd.topo_vertex in
      let ip = Node.ip label in
      ((string_of_ip ip), devid)::acc
    ) acc forwards
  ) [] flows in

  (* List.iter (fun (ip, port) -> *)
  (*   Printf.printf "-> %s %Ld\n" ip port ) (List.sort Pervasives.compare expected) *)
  (* Printf.printf "---------------\n"; *)
  (* List.iter (fun (ip, port) -> *)
  (*   Printf.printf "-> %s %Ld\n" ip port ) (List.sort Pervasives.compare got) *)

  if List.length expected !=  List.length got then
    false
  else
    List.fold_left2 (fun acc (ip1, port1) (ip2, port2) ->
      (ip1 = ip2) && (port1 = port2) && acc
    ) true (List.sort Pervasives.compare expected) (List.sort Pervasives.compare got)



(* let%test "./examples/speed/speed.mln" = test_solve "speed" = true *)
let%test "./examples/simple/simple.mln" = test_solve "simple" = true
let%test "./examples/sleuth/sleuth.mln" = test_solve "sleuth" = true
let%test "./examples/hadoop/hadoop.mln" = test_solve "hadoop" = true
let%test "./examples/codehash/codehash.mln" = test_solve "codehash" = true
let%test "./examples/defense/defense.mln" = test_solve "defense" = true
let%test "./examples/function/function.mln" = test_solve "function" = true
let%test "./examples/order/order.mln" = test_solve "order" = true
let%test "./examples/dpi_start/dpi_start.mln" = test_solve "dpi_end" = true
let%test "./examples/dpi_end/dpi_end.mln" = test_solve "dpi_end" = true
let%test "./examples/min/min.mln" = test_solve "min" = true
let%test "./examples/rateless/rateless.mln" = test_solve "rateless" = true
let%test "./examples/max/max.mln" = test_solve "max" = true
let%test "./examples/foreach/foreach.mln" = test_solve "foreach" = true
let%test "./examples/inline-set/inline-set.mln" = test_solve "inline-set" = true
