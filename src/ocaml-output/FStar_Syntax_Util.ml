
open Prims

let qual_id : FStar_Ident.lident  ->  FStar_Ident.ident  ->  FStar_Ident.lident = (fun lid id -> (let _133_5 = (FStar_Ident.lid_of_ids (FStar_List.append lid.FStar_Ident.ns ((lid.FStar_Ident.ident)::(id)::[])))
in (FStar_Ident.set_lid_range _133_5 id.FStar_Ident.idRange)))


let mk_discriminator : FStar_Ident.lident  ->  FStar_Ident.lident = (fun lid -> (FStar_Ident.lid_of_ids (FStar_List.append lid.FStar_Ident.ns (((FStar_Ident.mk_ident (((Prims.strcat FStar_Ident.reserved_prefix (Prims.strcat "is_" lid.FStar_Ident.ident.FStar_Ident.idText))), (lid.FStar_Ident.ident.FStar_Ident.idRange))))::[]))))


let is_name : FStar_Ident.lident  ->  Prims.bool = (fun lid -> (

let c = (FStar_Util.char_at lid.FStar_Ident.ident.FStar_Ident.idText (Prims.parse_int "0"))
in (FStar_Util.is_upper c)))


let arg_of_non_null_binder = (fun _38_18 -> (match (_38_18) with
| (b, imp) -> begin
(let _133_11 = (FStar_Syntax_Syntax.bv_to_name b)
in ((_133_11), (imp)))
end))


let args_of_non_null_binders : FStar_Syntax_Syntax.binders  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list = (fun binders -> (FStar_All.pipe_right binders (FStar_List.collect (fun b -> if (FStar_Syntax_Syntax.is_null_binder b) then begin
[]
end else begin
(let _133_15 = (arg_of_non_null_binder b)
in (_133_15)::[])
end))))


let args_of_binders : FStar_Syntax_Syntax.binders  ->  ((FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list * (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list) = (fun binders -> (let _133_22 = (FStar_All.pipe_right binders (FStar_List.map (fun b -> if (FStar_Syntax_Syntax.is_null_binder b) then begin
(

let b = (let _133_19 = (FStar_Syntax_Syntax.new_bv None (Prims.fst b).FStar_Syntax_Syntax.sort)
in ((_133_19), ((Prims.snd b))))
in (let _133_20 = (arg_of_non_null_binder b)
in ((b), (_133_20))))
end else begin
(let _133_21 = (arg_of_non_null_binder b)
in ((b), (_133_21)))
end)))
in (FStar_All.pipe_right _133_22 FStar_List.unzip)))


let name_binders : FStar_Syntax_Syntax.binder Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list = (fun binders -> (FStar_All.pipe_right binders (FStar_List.mapi (fun i b -> if (FStar_Syntax_Syntax.is_null_binder b) then begin
(

let _38_29 = b
in (match (_38_29) with
| (a, imp) -> begin
(

let b = (let _133_28 = (let _133_27 = (FStar_Util.string_of_int i)
in (Prims.strcat "_" _133_27))
in (FStar_Ident.id_of_text _133_28))
in (

let b = {FStar_Syntax_Syntax.ppname = b; FStar_Syntax_Syntax.index = (Prims.parse_int "0"); FStar_Syntax_Syntax.sort = a.FStar_Syntax_Syntax.sort}
in ((b), (imp))))
end))
end else begin
b
end))))


let name_function_binders = (fun t -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_arrow (binders, comp) -> begin
(let _133_32 = (let _133_31 = (let _133_30 = (name_binders binders)
in ((_133_30), (comp)))
in FStar_Syntax_Syntax.Tm_arrow (_133_31))
in (FStar_Syntax_Syntax.mk _133_32 None t.FStar_Syntax_Syntax.pos))
end
| _38_38 -> begin
t
end))


let null_binders_of_tks : (FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.aqual) Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) Prims.list = (fun tks -> (FStar_All.pipe_right tks (FStar_List.map (fun _38_42 -> (match (_38_42) with
| (t, imp) -> begin
(let _133_37 = (let _133_36 = (FStar_Syntax_Syntax.null_binder t)
in (FStar_All.pipe_left Prims.fst _133_36))
in ((_133_37), (imp)))
end)))))


let binders_of_tks : (FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.aqual) Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) Prims.list = (fun tks -> (FStar_All.pipe_right tks (FStar_List.map (fun _38_46 -> (match (_38_46) with
| (t, imp) -> begin
(let _133_41 = (FStar_Syntax_Syntax.new_bv (Some (t.FStar_Syntax_Syntax.pos)) t)
in ((_133_41), (imp)))
end)))))


let binders_of_freevars : FStar_Syntax_Syntax.bv FStar_Util.set  ->  FStar_Syntax_Syntax.binder Prims.list = (fun fvs -> (let _133_44 = (FStar_Util.set_elements fvs)
in (FStar_All.pipe_right _133_44 (FStar_List.map FStar_Syntax_Syntax.mk_binder))))


let mk_subst = (fun s -> (s)::[])


let subst_of_list : FStar_Syntax_Syntax.binders  ->  FStar_Syntax_Syntax.args  ->  FStar_Syntax_Syntax.subst_t = (fun formals actuals -> if ((FStar_List.length formals) = (FStar_List.length actuals)) then begin
(FStar_List.fold_right2 (fun f a out -> (FStar_Syntax_Syntax.NT ((((Prims.fst f)), ((Prims.fst a)))))::out) formals actuals [])
end else begin
(FStar_All.failwith "Ill-formed substitution")
end)


let rename_binders : FStar_Syntax_Syntax.binders  ->  FStar_Syntax_Syntax.binders  ->  FStar_Syntax_Syntax.subst_t = (fun replace_xs with_ys -> if ((FStar_List.length replace_xs) = (FStar_List.length with_ys)) then begin
(FStar_List.map2 (fun _38_59 _38_63 -> (match (((_38_59), (_38_63))) with
| ((x, _38_58), (y, _38_62)) -> begin
(let _133_60 = (let _133_59 = (FStar_Syntax_Syntax.bv_to_name y)
in ((x), (_133_59)))
in FStar_Syntax_Syntax.NT (_133_60))
end)) replace_xs with_ys)
end else begin
(FStar_All.failwith "Ill-formed substitution")
end)


let rec unmeta : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun e -> (

let e = (FStar_Syntax_Subst.compress e)
in (match (e.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_meta (e, _)) | (FStar_Syntax_Syntax.Tm_ascribed (e, _, _)) -> begin
(unmeta e)
end
| _38_78 -> begin
e
end)))


let rec univ_kernel : FStar_Syntax_Syntax.universe  ->  (FStar_Syntax_Syntax.universe * Prims.int) = (fun u -> (match (u) with
| (FStar_Syntax_Syntax.U_unknown) | (FStar_Syntax_Syntax.U_name (_)) | (FStar_Syntax_Syntax.U_unif (_)) | (FStar_Syntax_Syntax.U_zero) -> begin
((u), ((Prims.parse_int "0")))
end
| FStar_Syntax_Syntax.U_succ (u) -> begin
(

let _38_92 = (univ_kernel u)
in (match (_38_92) with
| (k, n) -> begin
((k), ((n + (Prims.parse_int "1"))))
end))
end
| FStar_Syntax_Syntax.U_max (_38_94) -> begin
(FStar_All.failwith "Imposible: univ_kernel (U_max _)")
end
| FStar_Syntax_Syntax.U_bvar (_38_97) -> begin
(FStar_All.failwith "Imposible: univ_kernel (U_bvar _)")
end))


let constant_univ_as_nat : FStar_Syntax_Syntax.universe  ->  Prims.int = (fun u -> (let _133_67 = (univ_kernel u)
in (Prims.snd _133_67)))


let rec compare_univs : FStar_Syntax_Syntax.universe  ->  FStar_Syntax_Syntax.universe  ->  Prims.int = (fun u1 u2 -> (match (((u1), (u2))) with
| ((FStar_Syntax_Syntax.U_bvar (_), _)) | ((_, FStar_Syntax_Syntax.U_bvar (_))) -> begin
(FStar_All.failwith "Impossible: compare_univs")
end
| (FStar_Syntax_Syntax.U_unknown, FStar_Syntax_Syntax.U_unknown) -> begin
(Prims.parse_int "0")
end
| (FStar_Syntax_Syntax.U_unknown, _38_119) -> begin
(~- ((Prims.parse_int "1")))
end
| (_38_122, FStar_Syntax_Syntax.U_unknown) -> begin
(Prims.parse_int "1")
end
| (FStar_Syntax_Syntax.U_zero, FStar_Syntax_Syntax.U_zero) -> begin
(Prims.parse_int "0")
end
| (FStar_Syntax_Syntax.U_zero, _38_130) -> begin
(~- ((Prims.parse_int "1")))
end
| (_38_133, FStar_Syntax_Syntax.U_zero) -> begin
(Prims.parse_int "1")
end
| (FStar_Syntax_Syntax.U_name (u1), FStar_Syntax_Syntax.U_name (u2)) -> begin
(FStar_String.compare u1.FStar_Ident.idText u2.FStar_Ident.idText)
end
| (FStar_Syntax_Syntax.U_name (_38_142), FStar_Syntax_Syntax.U_unif (_38_145)) -> begin
(~- ((Prims.parse_int "1")))
end
| (FStar_Syntax_Syntax.U_unif (_38_149), FStar_Syntax_Syntax.U_name (_38_152)) -> begin
(Prims.parse_int "1")
end
| (FStar_Syntax_Syntax.U_unif (u1), FStar_Syntax_Syntax.U_unif (u2)) -> begin
((FStar_Unionfind.uvar_id u1) - (FStar_Unionfind.uvar_id u2))
end
| (FStar_Syntax_Syntax.U_max (us1), FStar_Syntax_Syntax.U_max (us2)) -> begin
(

let n1 = (FStar_List.length us1)
in (

let n2 = (FStar_List.length us2)
in if (n1 <> n2) then begin
(n1 - n2)
end else begin
(

let copt = (let _133_73 = (FStar_List.zip us1 us2)
in (FStar_Util.find_map _133_73 (fun _38_169 -> (match (_38_169) with
| (u1, u2) -> begin
(

let c = (compare_univs u1 u2)
in if (c <> (Prims.parse_int "0")) then begin
Some (c)
end else begin
None
end)
end))))
in (match (copt) with
| None -> begin
(Prims.parse_int "0")
end
| Some (c) -> begin
c
end))
end))
end
| (FStar_Syntax_Syntax.U_max (_38_176), _38_179) -> begin
(~- ((Prims.parse_int "1")))
end
| (_38_182, FStar_Syntax_Syntax.U_max (_38_184)) -> begin
(Prims.parse_int "1")
end
| _38_188 -> begin
(

let _38_191 = (univ_kernel u1)
in (match (_38_191) with
| (k1, n1) -> begin
(

let _38_194 = (univ_kernel u2)
in (match (_38_194) with
| (k2, n2) -> begin
(

let r = (compare_univs k1 k2)
in if (r = (Prims.parse_int "0")) then begin
(n1 - n2)
end else begin
r
end)
end))
end))
end))


let eq_univs : FStar_Syntax_Syntax.universe  ->  FStar_Syntax_Syntax.universe  ->  Prims.bool = (fun u1 u2 -> ((compare_univs u1 u2) = (Prims.parse_int "0")))


let ml_comp : FStar_Syntax_Syntax.typ  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.comp = (fun t r -> (FStar_Syntax_Syntax.mk_Comp {FStar_Syntax_Syntax.comp_univs = (FStar_Syntax_Syntax.U_unknown)::[]; FStar_Syntax_Syntax.effect_name = (FStar_Ident.set_lid_range FStar_Syntax_Const.effect_ML_lid r); FStar_Syntax_Syntax.result_typ = t; FStar_Syntax_Syntax.effect_args = []; FStar_Syntax_Syntax.flags = (FStar_Syntax_Syntax.MLEFFECT)::[]}))


let comp_set_flags : FStar_Syntax_Syntax.comp  ->  FStar_Syntax_Syntax.cflags Prims.list  ->  FStar_Syntax_Syntax.comp = (fun c f -> (match (c.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Total (_)) | (FStar_Syntax_Syntax.GTotal (_)) -> begin
c
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
(

let _38_210 = c
in {FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Comp ((

let _38_212 = ct
in {FStar_Syntax_Syntax.comp_univs = _38_212.FStar_Syntax_Syntax.comp_univs; FStar_Syntax_Syntax.effect_name = _38_212.FStar_Syntax_Syntax.effect_name; FStar_Syntax_Syntax.result_typ = _38_212.FStar_Syntax_Syntax.result_typ; FStar_Syntax_Syntax.effect_args = _38_212.FStar_Syntax_Syntax.effect_args; FStar_Syntax_Syntax.flags = f})); FStar_Syntax_Syntax.tk = _38_210.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = _38_210.FStar_Syntax_Syntax.pos; FStar_Syntax_Syntax.vars = _38_210.FStar_Syntax_Syntax.vars})
end))


let comp_flags = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (_38_216) -> begin
(FStar_Syntax_Syntax.TOTAL)::[]
end
| FStar_Syntax_Syntax.GTotal (_38_219) -> begin
(FStar_Syntax_Syntax.SOMETRIVIAL)::[]
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
ct.FStar_Syntax_Syntax.flags
end))


let comp_effect_name = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Comp (c) -> begin
c.FStar_Syntax_Syntax.effect_name
end
| FStar_Syntax_Syntax.Total (_38_227) -> begin
FStar_Syntax_Const.effect_Tot_lid
end
| FStar_Syntax_Syntax.GTotal (_38_230) -> begin
FStar_Syntax_Const.effect_GTot_lid
end))


let comp_to_comp_typ : FStar_Syntax_Syntax.comp  ->  FStar_Syntax_Syntax.comp_typ = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Comp (c) -> begin
c
end
| (FStar_Syntax_Syntax.Total (t, Some (u))) | (FStar_Syntax_Syntax.GTotal (t, Some (u))) -> begin
{FStar_Syntax_Syntax.comp_univs = (u)::[]; FStar_Syntax_Syntax.effect_name = (comp_effect_name c); FStar_Syntax_Syntax.result_typ = t; FStar_Syntax_Syntax.effect_args = []; FStar_Syntax_Syntax.flags = (comp_flags c)}
end
| _38_244 -> begin
(FStar_All.failwith "Assertion failed: Computation type without universe")
end))


let is_total_comp = (fun c -> (FStar_All.pipe_right (comp_flags c) (FStar_Util.for_some (fun _38_1 -> (match (_38_1) with
| (FStar_Syntax_Syntax.TOTAL) | (FStar_Syntax_Syntax.RETURN) -> begin
true
end
| _38_250 -> begin
false
end)))))


let is_total_lcomp : FStar_Syntax_Syntax.lcomp  ->  Prims.bool = (fun c -> ((FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name FStar_Syntax_Const.effect_Tot_lid) || (FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags (FStar_Util.for_some (fun _38_2 -> (match (_38_2) with
| (FStar_Syntax_Syntax.TOTAL) | (FStar_Syntax_Syntax.RETURN) -> begin
true
end
| _38_256 -> begin
false
end))))))


let is_tot_or_gtot_lcomp : FStar_Syntax_Syntax.lcomp  ->  Prims.bool = (fun c -> (((FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name FStar_Syntax_Const.effect_Tot_lid) || (FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name FStar_Syntax_Const.effect_GTot_lid)) || (FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags (FStar_Util.for_some (fun _38_3 -> (match (_38_3) with
| (FStar_Syntax_Syntax.TOTAL) | (FStar_Syntax_Syntax.RETURN) -> begin
true
end
| _38_262 -> begin
false
end))))))


let is_partial_return = (fun c -> (FStar_All.pipe_right (comp_flags c) (FStar_Util.for_some (fun _38_4 -> (match (_38_4) with
| (FStar_Syntax_Syntax.RETURN) | (FStar_Syntax_Syntax.PARTIAL_RETURN) -> begin
true
end
| _38_268 -> begin
false
end)))))


let is_lcomp_partial_return : FStar_Syntax_Syntax.lcomp  ->  Prims.bool = (fun c -> (FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags (FStar_Util.for_some (fun _38_5 -> (match (_38_5) with
| (FStar_Syntax_Syntax.RETURN) | (FStar_Syntax_Syntax.PARTIAL_RETURN) -> begin
true
end
| _38_274 -> begin
false
end)))))


let is_tot_or_gtot_comp = (fun c -> ((is_total_comp c) || (FStar_Ident.lid_equals FStar_Syntax_Const.effect_GTot_lid (comp_effect_name c))))


let is_pure_effect : FStar_Ident.lident  ->  Prims.bool = (fun l -> (((FStar_Ident.lid_equals l FStar_Syntax_Const.effect_Tot_lid) || (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_PURE_lid)) || (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_Pure_lid)))


let is_pure_comp = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (_38_279) -> begin
true
end
| FStar_Syntax_Syntax.GTotal (_38_282) -> begin
false
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
(((is_total_comp c) || (is_pure_effect ct.FStar_Syntax_Syntax.effect_name)) || (FStar_All.pipe_right ct.FStar_Syntax_Syntax.flags (FStar_Util.for_some (fun _38_6 -> (match (_38_6) with
| FStar_Syntax_Syntax.LEMMA -> begin
true
end
| _38_289 -> begin
false
end)))))
end))


let is_ghost_effect : FStar_Ident.lident  ->  Prims.bool = (fun l -> (((FStar_Ident.lid_equals FStar_Syntax_Const.effect_GTot_lid l) || (FStar_Ident.lid_equals FStar_Syntax_Const.effect_GHOST_lid l)) || (FStar_Ident.lid_equals FStar_Syntax_Const.effect_Ghost_lid l)))


let is_pure_or_ghost_comp = (fun c -> ((is_pure_comp c) || (is_ghost_effect (comp_effect_name c))))


let is_pure_lcomp : FStar_Syntax_Syntax.lcomp  ->  Prims.bool = (fun lc -> (((is_total_lcomp lc) || (is_pure_effect lc.FStar_Syntax_Syntax.eff_name)) || (FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags (FStar_Util.for_some (fun _38_7 -> (match (_38_7) with
| FStar_Syntax_Syntax.LEMMA -> begin
true
end
| _38_296 -> begin
false
end))))))


let is_pure_or_ghost_lcomp : FStar_Syntax_Syntax.lcomp  ->  Prims.bool = (fun lc -> ((is_pure_lcomp lc) || (is_ghost_effect lc.FStar_Syntax_Syntax.eff_name)))


let is_pure_or_ghost_function : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_118 = (FStar_Syntax_Subst.compress t)
in _133_118.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (_38_300, c) -> begin
(is_pure_or_ghost_comp c)
end
| _38_305 -> begin
true
end))


let is_lemma : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_121 = (FStar_Syntax_Subst.compress t)
in _133_121.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (_38_308, c) -> begin
(match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Comp (ct) -> begin
(FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name FStar_Syntax_Const.effect_Lemma_lid)
end
| _38_315 -> begin
false
end)
end
| _38_317 -> begin
false
end))


let head_and_args : FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.args) = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app (head, args) -> begin
((head), (args))
end
| _38_325 -> begin
((t), ([]))
end)))


let un_uinst : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_uinst (t, _38_330) -> begin
(FStar_Syntax_Subst.compress t)
end
| _38_334 -> begin
t
end)))


let is_smt_lemma : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_128 = (FStar_Syntax_Subst.compress t)
in _133_128.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (_38_337, c) -> begin
(match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Comp (ct) when (FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name FStar_Syntax_Const.effect_Lemma_lid) -> begin
(match (ct.FStar_Syntax_Syntax.effect_args) with
| (_req)::(_ens)::((pats, _38_347))::_38_344 -> begin
(

let pats' = (unmeta pats)
in (

let _38_358 = (head_and_args pats')
in (match (_38_358) with
| (head, _38_357) -> begin
(match ((let _133_129 = (un_uinst head)
in _133_129.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.cons_lid)
end
| _38_362 -> begin
false
end)
end)))
end
| _38_364 -> begin
false
end)
end
| _38_366 -> begin
false
end)
end
| _38_368 -> begin
false
end))


let is_ml_comp = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Comp (c) -> begin
((FStar_Ident.lid_equals c.FStar_Syntax_Syntax.effect_name FStar_Syntax_Const.effect_ML_lid) || (FStar_All.pipe_right c.FStar_Syntax_Syntax.flags (FStar_Util.for_some (fun _38_8 -> (match (_38_8) with
| FStar_Syntax_Syntax.MLEFFECT -> begin
true
end
| _38_375 -> begin
false
end)))))
end
| _38_377 -> begin
false
end))


let comp_result = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Total (t, _)) | (FStar_Syntax_Syntax.GTotal (t, _)) -> begin
t
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
ct.FStar_Syntax_Syntax.result_typ
end))


let set_result_typ = (fun c t -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (_38_393) -> begin
(FStar_Syntax_Syntax.mk_Total t)
end
| FStar_Syntax_Syntax.GTotal (_38_396) -> begin
(FStar_Syntax_Syntax.mk_GTotal t)
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
(FStar_Syntax_Syntax.mk_Comp (

let _38_400 = ct
in {FStar_Syntax_Syntax.comp_univs = _38_400.FStar_Syntax_Syntax.comp_univs; FStar_Syntax_Syntax.effect_name = _38_400.FStar_Syntax_Syntax.effect_name; FStar_Syntax_Syntax.result_typ = t; FStar_Syntax_Syntax.effect_args = _38_400.FStar_Syntax_Syntax.effect_args; FStar_Syntax_Syntax.flags = _38_400.FStar_Syntax_Syntax.flags}))
end))


let is_trivial_wp = (fun c -> (FStar_All.pipe_right (comp_flags c) (FStar_Util.for_some (fun _38_9 -> (match (_38_9) with
| (FStar_Syntax_Syntax.TOTAL) | (FStar_Syntax_Syntax.RETURN) -> begin
true
end
| _38_407 -> begin
false
end)))))


let primops : FStar_Ident.lident Prims.list = (FStar_Syntax_Const.op_Eq)::(FStar_Syntax_Const.op_notEq)::(FStar_Syntax_Const.op_LT)::(FStar_Syntax_Const.op_LTE)::(FStar_Syntax_Const.op_GT)::(FStar_Syntax_Const.op_GTE)::(FStar_Syntax_Const.op_Subtraction)::(FStar_Syntax_Const.op_Minus)::(FStar_Syntax_Const.op_Addition)::(FStar_Syntax_Const.op_Multiply)::(FStar_Syntax_Const.op_Division)::(FStar_Syntax_Const.op_Modulus)::(FStar_Syntax_Const.op_And)::(FStar_Syntax_Const.op_Or)::(FStar_Syntax_Const.op_Negation)::[]


let is_primop_lid : FStar_Ident.lident  ->  Prims.bool = (fun l -> (FStar_All.pipe_right primops (FStar_Util.for_some (FStar_Ident.lid_equals l))))


let is_primop = (fun f -> (match (f.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(is_primop_lid fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end
| _38_413 -> begin
false
end))


let rec unascribe : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun e -> (

let e = (FStar_Syntax_Subst.compress e)
in (match (e.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_ascribed (e, _38_418, _38_420) -> begin
(unascribe e)
end
| _38_424 -> begin
e
end)))


let rec ascribe = (fun t k -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_ascribed (t', _38_429, _38_431) -> begin
(ascribe t' k)
end
| _38_435 -> begin
(FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_ascribed (((t), (k), (None)))) None t.FStar_Syntax_Syntax.pos)
end))


let rec unrefine : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_refine (x, _38_440) -> begin
(unrefine x.FStar_Syntax_Syntax.sort)
end
| FStar_Syntax_Syntax.Tm_ascribed (t, _38_445, _38_447) -> begin
(unrefine t)
end
| _38_451 -> begin
t
end)))


let rec is_unit : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_148 = (unrefine t)
in _133_148.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_type (_38_454) -> begin
true
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
((FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.unit_lid) || (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.squash_lid))
end
| FStar_Syntax_Syntax.Tm_uinst (t, _38_460) -> begin
(is_unit t)
end
| _38_464 -> begin
false
end))


let rec non_informative : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_151 = (unrefine t)
in _133_151.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_type (_38_467) -> begin
true
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(((FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.unit_lid) || (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.squash_lid)) || (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.erased_lid))
end
| FStar_Syntax_Syntax.Tm_app (head, _38_473) -> begin
(non_informative head)
end
| FStar_Syntax_Syntax.Tm_uinst (t, _38_478) -> begin
(non_informative t)
end
| FStar_Syntax_Syntax.Tm_arrow (_38_482, c) -> begin
((is_tot_or_gtot_comp c) && (non_informative (comp_result c)))
end
| _38_487 -> begin
false
end))


let is_fun : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun e -> (match ((let _133_154 = (FStar_Syntax_Subst.compress e)
in _133_154.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_abs (_38_490) -> begin
true
end
| _38_493 -> begin
false
end))


let is_function_typ : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_157 = (FStar_Syntax_Subst.compress t)
in _133_157.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (_38_496) -> begin
true
end
| _38_499 -> begin
false
end))


let rec pre_typ : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_refine (x, _38_504) -> begin
(pre_typ x.FStar_Syntax_Syntax.sort)
end
| FStar_Syntax_Syntax.Tm_ascribed (t, _38_509, _38_511) -> begin
(pre_typ t)
end
| _38_515 -> begin
t
end)))


let destruct : FStar_Syntax_Syntax.term  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.args Prims.option = (fun typ lid -> (

let typ = (FStar_Syntax_Subst.compress typ)
in (match ((let _133_164 = (un_uinst typ)
in _133_164.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_app (head, args) -> begin
(

let head = (un_uinst head)
in (match (head.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (tc) when (FStar_Syntax_Syntax.fv_eq_lid tc lid) -> begin
Some (args)
end
| _38_527 -> begin
None
end))
end
| FStar_Syntax_Syntax.Tm_fvar (tc) when (FStar_Syntax_Syntax.fv_eq_lid tc lid) -> begin
Some ([])
end
| _38_531 -> begin
None
end)))


let rec lids_of_sigelt : FStar_Syntax_Syntax.sigelt  ->  FStar_Ident.lident Prims.list = (fun se -> (match (se) with
| (FStar_Syntax_Syntax.Sig_let (_, _, lids, _)) | (FStar_Syntax_Syntax.Sig_bundle (_, _, lids, _)) -> begin
lids
end
| (FStar_Syntax_Syntax.Sig_inductive_typ (lid, _, _, _, _, _, _, _)) | (FStar_Syntax_Syntax.Sig_effect_abbrev (lid, _, _, _, _, _)) | (FStar_Syntax_Syntax.Sig_datacon (lid, _, _, _, _, _, _, _)) | (FStar_Syntax_Syntax.Sig_declare_typ (lid, _, _, _, _)) | (FStar_Syntax_Syntax.Sig_assume (lid, _, _, _)) -> begin
(lid)::[]
end
| (FStar_Syntax_Syntax.Sig_new_effect_for_free (n, _)) | (FStar_Syntax_Syntax.Sig_new_effect (n, _)) -> begin
(n.FStar_Syntax_Syntax.mname)::[]
end
| (FStar_Syntax_Syntax.Sig_sub_effect (_)) | (FStar_Syntax_Syntax.Sig_pragma (_)) | (FStar_Syntax_Syntax.Sig_main (_)) -> begin
[]
end))


let lid_of_sigelt : FStar_Syntax_Syntax.sigelt  ->  FStar_Ident.lident Prims.option = (fun se -> (match ((lids_of_sigelt se)) with
| (l)::[] -> begin
Some (l)
end
| _38_635 -> begin
None
end))


let quals_of_sigelt : FStar_Syntax_Syntax.sigelt  ->  FStar_Syntax_Syntax.qualifier Prims.list = (fun x -> (match (x) with
| (FStar_Syntax_Syntax.Sig_bundle (_, quals, _, _)) | (FStar_Syntax_Syntax.Sig_inductive_typ (_, _, _, _, _, _, quals, _)) | (FStar_Syntax_Syntax.Sig_effect_abbrev (_, _, _, _, quals, _)) | (FStar_Syntax_Syntax.Sig_datacon (_, _, _, _, _, quals, _, _)) | (FStar_Syntax_Syntax.Sig_declare_typ (_, _, _, quals, _)) | (FStar_Syntax_Syntax.Sig_assume (_, _, quals, _)) | (FStar_Syntax_Syntax.Sig_let (_, _, _, quals)) | (FStar_Syntax_Syntax.Sig_new_effect ({FStar_Syntax_Syntax.qualifiers = quals; FStar_Syntax_Syntax.cattributes = _; FStar_Syntax_Syntax.mname = _; FStar_Syntax_Syntax.univs = _; FStar_Syntax_Syntax.binders = _; FStar_Syntax_Syntax.signature = _; FStar_Syntax_Syntax.ret_wp = _; FStar_Syntax_Syntax.bind_wp = _; FStar_Syntax_Syntax.if_then_else = _; FStar_Syntax_Syntax.ite_wp = _; FStar_Syntax_Syntax.stronger = _; FStar_Syntax_Syntax.close_wp = _; FStar_Syntax_Syntax.assert_p = _; FStar_Syntax_Syntax.assume_p = _; FStar_Syntax_Syntax.null_wp = _; FStar_Syntax_Syntax.trivial = _; FStar_Syntax_Syntax.repr = _; FStar_Syntax_Syntax.return_repr = _; FStar_Syntax_Syntax.bind_repr = _; FStar_Syntax_Syntax.actions = _}, _)) | (FStar_Syntax_Syntax.Sig_new_effect_for_free ({FStar_Syntax_Syntax.qualifiers = quals; FStar_Syntax_Syntax.cattributes = _; FStar_Syntax_Syntax.mname = _; FStar_Syntax_Syntax.univs = _; FStar_Syntax_Syntax.binders = _; FStar_Syntax_Syntax.signature = _; FStar_Syntax_Syntax.ret_wp = _; FStar_Syntax_Syntax.bind_wp = _; FStar_Syntax_Syntax.if_then_else = _; FStar_Syntax_Syntax.ite_wp = _; FStar_Syntax_Syntax.stronger = _; FStar_Syntax_Syntax.close_wp = _; FStar_Syntax_Syntax.assert_p = _; FStar_Syntax_Syntax.assume_p = _; FStar_Syntax_Syntax.null_wp = _; FStar_Syntax_Syntax.trivial = _; FStar_Syntax_Syntax.repr = _; FStar_Syntax_Syntax.return_repr = _; FStar_Syntax_Syntax.bind_repr = _; FStar_Syntax_Syntax.actions = _}, _)) -> begin
quals
end
| (FStar_Syntax_Syntax.Sig_sub_effect (_, _)) | (FStar_Syntax_Syntax.Sig_pragma (_, _)) | (FStar_Syntax_Syntax.Sig_main (_, _)) -> begin
[]
end))


let range_of_sigelt : FStar_Syntax_Syntax.sigelt  ->  FStar_Range.range = (fun x -> (match (x) with
| (FStar_Syntax_Syntax.Sig_bundle (_, _, _, r)) | (FStar_Syntax_Syntax.Sig_inductive_typ (_, _, _, _, _, _, _, r)) | (FStar_Syntax_Syntax.Sig_effect_abbrev (_, _, _, _, _, r)) | (FStar_Syntax_Syntax.Sig_datacon (_, _, _, _, _, _, _, r)) | (FStar_Syntax_Syntax.Sig_declare_typ (_, _, _, _, r)) | (FStar_Syntax_Syntax.Sig_assume (_, _, _, r)) | (FStar_Syntax_Syntax.Sig_let (_, r, _, _)) | (FStar_Syntax_Syntax.Sig_main (_, r)) | (FStar_Syntax_Syntax.Sig_pragma (_, r)) | (FStar_Syntax_Syntax.Sig_new_effect (_, r)) | (FStar_Syntax_Syntax.Sig_new_effect_for_free (_, r)) | (FStar_Syntax_Syntax.Sig_sub_effect (_, r)) -> begin
r
end))


let range_of_lb = (fun _38_10 -> (match (_38_10) with
| (FStar_Util.Inl (x), _38_924, _38_926) -> begin
(FStar_Syntax_Syntax.range_of_bv x)
end
| (FStar_Util.Inr (l), _38_931, _38_933) -> begin
(FStar_Ident.range_of_lid l)
end))


let range_of_arg = (fun _38_938 -> (match (_38_938) with
| (hd, _38_937) -> begin
hd.FStar_Syntax_Syntax.pos
end))


let range_of_args = (fun args r -> (FStar_All.pipe_right args (FStar_List.fold_left (fun r a -> (FStar_Range.union_ranges r (range_of_arg a))) r)))


let mk_app = (fun f args -> (

let r = (range_of_args args f.FStar_Syntax_Syntax.pos)
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app (((f), (args)))) None r)))


let mk_data = (fun l args -> (match (args) with
| [] -> begin
(let _133_185 = (let _133_184 = (let _133_183 = (FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in ((_133_183), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app))))
in FStar_Syntax_Syntax.Tm_meta (_133_184))
in (FStar_Syntax_Syntax.mk _133_185 None (FStar_Ident.range_of_lid l)))
end
| _38_950 -> begin
(

let e = (let _133_186 = (FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in (mk_app _133_186 args))
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_meta (((e), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app))))) None e.FStar_Syntax_Syntax.pos))
end))


let mangle_field_name : FStar_Ident.ident  ->  FStar_Ident.ident = (fun x -> (FStar_Ident.mk_ident (((Prims.strcat "^fname^" x.FStar_Ident.idText)), (x.FStar_Ident.idRange))))


let unmangle_field_name : FStar_Ident.ident  ->  FStar_Ident.ident = (fun x -> if (FStar_Util.starts_with x.FStar_Ident.idText "^fname^") then begin
(let _133_192 = (let _133_191 = (FStar_Util.substring_from x.FStar_Ident.idText (Prims.parse_int "7"))
in ((_133_191), (x.FStar_Ident.idRange)))
in (FStar_Ident.mk_ident _133_192))
end else begin
x
end)


let field_projector_prefix : Prims.string = "__proj__"


let field_projector_sep : Prims.string = "__item__"


let field_projector_contains_constructor : Prims.string  ->  Prims.bool = (fun s -> (FStar_Util.starts_with s field_projector_prefix))


let mk_field_projector_name_from_string : Prims.string  ->  Prims.string  ->  Prims.string = (fun constr field -> (Prims.strcat field_projector_prefix (Prims.strcat constr (Prims.strcat field_projector_sep field))))


let mk_field_projector_name_from_ident : FStar_Ident.lident  ->  FStar_Ident.ident  ->  FStar_Ident.lident = (fun lid i -> (

let j = (unmangle_field_name i)
in (

let jtext = j.FStar_Ident.idText
in (

let newi = if (field_projector_contains_constructor jtext) then begin
j
end else begin
(FStar_Ident.mk_ident (((mk_field_projector_name_from_string lid.FStar_Ident.ident.FStar_Ident.idText jtext)), (i.FStar_Ident.idRange)))
end
in (FStar_Ident.lid_of_ids (FStar_List.append lid.FStar_Ident.ns ((newi)::[])))))))


let mk_field_projector_name : FStar_Ident.lident  ->  FStar_Syntax_Syntax.bv  ->  Prims.int  ->  (FStar_Ident.lident * FStar_Syntax_Syntax.bv) = (fun lid x i -> (

let nm = if (FStar_Syntax_Syntax.is_null_bv x) then begin
(let _133_212 = (let _133_211 = (let _133_209 = (FStar_Util.string_of_int i)
in (Prims.strcat "_" _133_209))
in (let _133_210 = (FStar_Syntax_Syntax.range_of_bv x)
in ((_133_211), (_133_210))))
in (FStar_Ident.mk_ident _133_212))
end else begin
x.FStar_Syntax_Syntax.ppname
end
in (

let y = (

let _38_966 = x
in {FStar_Syntax_Syntax.ppname = nm; FStar_Syntax_Syntax.index = _38_966.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = _38_966.FStar_Syntax_Syntax.sort})
in (let _133_213 = (mk_field_projector_name_from_ident lid nm)
in ((_133_213), (y))))))


let set_uvar = (fun uv t -> (match ((FStar_Unionfind.find uv)) with
| FStar_Syntax_Syntax.Fixed (_38_972) -> begin
(let _133_218 = (let _133_217 = (let _133_216 = (FStar_Unionfind.uvar_id uv)
in (FStar_All.pipe_left FStar_Util.string_of_int _133_216))
in (FStar_Util.format1 "Changing a fixed uvar! ?%s\n" _133_217))
in (FStar_All.failwith _133_218))
end
| _38_975 -> begin
(FStar_Unionfind.change uv (FStar_Syntax_Syntax.Fixed (t)))
end))


let qualifier_equal : FStar_Syntax_Syntax.qualifier  ->  FStar_Syntax_Syntax.qualifier  ->  Prims.bool = (fun q1 q2 -> (match (((q1), (q2))) with
| (FStar_Syntax_Syntax.Discriminator (l1), FStar_Syntax_Syntax.Discriminator (l2)) -> begin
(FStar_Ident.lid_equals l1 l2)
end
| (FStar_Syntax_Syntax.Projector (l1a, l1b), FStar_Syntax_Syntax.Projector (l2a, l2b)) -> begin
((FStar_Ident.lid_equals l1a l2a) && (l1b.FStar_Ident.idText = l2b.FStar_Ident.idText))
end
| ((FStar_Syntax_Syntax.RecordType (f1), FStar_Syntax_Syntax.RecordType (f2))) | ((FStar_Syntax_Syntax.RecordConstructor (f1), FStar_Syntax_Syntax.RecordConstructor (f2))) -> begin
(((FStar_List.length f1) = (FStar_List.length f2)) && (FStar_List.forall2 FStar_Ident.lid_equals f1 f2))
end
| _38_1001 -> begin
(q1 = q2)
end))


let abs : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.lcomp, FStar_Ident.lident) FStar_Util.either Prims.option  ->  FStar_Syntax_Syntax.term = (fun bs t lopt -> if ((FStar_List.length bs) = (Prims.parse_int "0")) then begin
t
end else begin
(

let close_lopt = (fun lopt -> (match (lopt) with
| (None) | (Some (FStar_Util.Inr (_))) -> begin
lopt
end
| Some (FStar_Util.Inl (lc)) -> begin
(let _133_232 = (let _133_231 = (FStar_Syntax_Subst.close_lcomp bs lc)
in FStar_Util.Inl (_133_231))
in Some (_133_232))
end))
in (match (bs) with
| [] -> begin
t
end
| _38_1017 -> begin
(

let body = (let _133_233 = (FStar_Syntax_Subst.close bs t)
in (FStar_Syntax_Subst.compress _133_233))
in (match (((body.FStar_Syntax_Syntax.n), (lopt))) with
| (FStar_Syntax_Syntax.Tm_abs (bs', t, lopt'), None) -> begin
(let _133_238 = (let _133_237 = (let _133_236 = (let _133_234 = (FStar_Syntax_Subst.close_binders bs)
in (FStar_List.append _133_234 bs'))
in (let _133_235 = (close_lopt lopt')
in ((_133_236), (t), (_133_235))))
in FStar_Syntax_Syntax.Tm_abs (_133_237))
in (FStar_Syntax_Syntax.mk _133_238 None t.FStar_Syntax_Syntax.pos))
end
| _38_1027 -> begin
(

let lopt = (match (lopt) with
| (None) | (Some (FStar_Util.Inr (_))) -> begin
lopt
end
| Some (FStar_Util.Inl (lc)) -> begin
(let _133_240 = (let _133_239 = (FStar_Syntax_Subst.close_lcomp bs lc)
in FStar_Util.Inl (_133_239))
in Some (_133_240))
end)
in (let _133_243 = (let _133_242 = (let _133_241 = (FStar_Syntax_Subst.close_binders bs)
in ((_133_241), (body), (lopt)))
in FStar_Syntax_Syntax.Tm_abs (_133_242))
in (FStar_Syntax_Syntax.mk _133_243 None t.FStar_Syntax_Syntax.pos)))
end))
end))
end)


let arrow : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax  ->  FStar_Syntax_Syntax.typ = (fun bs c -> (match (bs) with
| [] -> begin
(comp_result c)
end
| _38_1041 -> begin
(let _133_251 = (let _133_250 = (let _133_249 = (FStar_Syntax_Subst.close_binders bs)
in (let _133_248 = (FStar_Syntax_Subst.close_comp bs c)
in ((_133_249), (_133_248))))
in FStar_Syntax_Syntax.Tm_arrow (_133_250))
in (FStar_Syntax_Syntax.mk _133_251 None c.FStar_Syntax_Syntax.pos))
end))


let flat_arrow : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun bs c -> (

let t = (arrow bs c)
in (match ((let _133_256 = (FStar_Syntax_Subst.compress t)
in _133_256.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (tres, _38_1051) -> begin
(match ((let _133_257 = (FStar_Syntax_Subst.compress tres)
in _133_257.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (bs', c') -> begin
(let _133_258 = (FStar_ST.read t.FStar_Syntax_Syntax.tk)
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_arrow ((((FStar_List.append bs bs')), (c')))) _133_258 t.FStar_Syntax_Syntax.pos))
end
| _38_1059 -> begin
t
end)
end
| _38_1061 -> begin
t
end)
end
| _38_1063 -> begin
t
end)))


let refine : FStar_Syntax_Syntax.bv  ->  FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun b t -> (let _133_270 = (let _133_266 = (let _133_265 = (let _133_264 = (let _133_263 = (FStar_Syntax_Syntax.mk_binder b)
in (_133_263)::[])
in (FStar_Syntax_Subst.close _133_264 t))
in ((b), (_133_265)))
in FStar_Syntax_Syntax.Tm_refine (_133_266))
in (let _133_269 = (FStar_ST.read b.FStar_Syntax_Syntax.sort.FStar_Syntax_Syntax.tk)
in (let _133_268 = (let _133_267 = (FStar_Syntax_Syntax.range_of_bv b)
in (FStar_Range.union_ranges _133_267 t.FStar_Syntax_Syntax.pos))
in (FStar_Syntax_Syntax.mk _133_270 _133_269 _133_268)))))


let branch : FStar_Syntax_Syntax.branch  ->  FStar_Syntax_Syntax.branch = (fun b -> (FStar_Syntax_Subst.close_branch b))


let rec arrow_formals_comp : FStar_Syntax_Syntax.term  ->  ((FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list * FStar_Syntax_Syntax.comp) = (fun k -> (

let k = (FStar_Syntax_Subst.compress k)
in (match (k.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(

let _38_1075 = (FStar_Syntax_Subst.open_comp bs c)
in (match (_38_1075) with
| (bs, c) -> begin
if (is_tot_or_gtot_comp c) then begin
(

let _38_1078 = (arrow_formals_comp (comp_result c))
in (match (_38_1078) with
| (bs', k) -> begin
(((FStar_List.append bs bs')), (k))
end))
end else begin
((bs), (c))
end
end))
end
| _38_1080 -> begin
(let _133_275 = (FStar_Syntax_Syntax.mk_Total k)
in (([]), (_133_275)))
end)))


let rec arrow_formals : FStar_Syntax_Syntax.term  ->  ((FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list * FStar_Syntax_Syntax.typ) = (fun k -> (

let _38_1084 = (arrow_formals_comp k)
in (match (_38_1084) with
| (bs, c) -> begin
((bs), ((comp_result c)))
end)))


let abs_formals : FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.term * (FStar_Syntax_Syntax.lcomp, FStar_Ident.lident) FStar_Util.either Prims.option) = (fun t -> (

let rec aux = (fun t what -> (match ((let _133_285 = (let _133_284 = (FStar_Syntax_Subst.compress t)
in (FStar_All.pipe_left unascribe _133_284))
in _133_285.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_abs (bs, t, what) -> begin
(

let _38_1097 = (aux t what)
in (match (_38_1097) with
| (bs', t, what) -> begin
(((FStar_List.append bs bs')), (t), (what))
end))
end
| _38_1099 -> begin
(([]), (t), (what))
end))
in (

let _38_1103 = (aux t None)
in (match (_38_1103) with
| (bs, t, what) -> begin
(

let _38_1106 = (FStar_Syntax_Subst.open_term bs t)
in (match (_38_1106) with
| (bs, t) -> begin
((bs), (t), (what))
end))
end))))


let mk_letbinding : FStar_Syntax_Syntax.lbname  ->  FStar_Syntax_Syntax.univ_name Prims.list  ->  FStar_Syntax_Syntax.typ  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.letbinding = (fun lbname univ_vars typ eff def -> {FStar_Syntax_Syntax.lbname = lbname; FStar_Syntax_Syntax.lbunivs = univ_vars; FStar_Syntax_Syntax.lbtyp = typ; FStar_Syntax_Syntax.lbeff = eff; FStar_Syntax_Syntax.lbdef = def})


let close_univs_and_mk_letbinding : FStar_Syntax_Syntax.fv Prims.list Prims.option  ->  FStar_Syntax_Syntax.lbname  ->  FStar_Syntax_Syntax.univ_name Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.letbinding = (fun recs lbname univ_vars typ eff def -> (

let def = (match (((recs), (univ_vars))) with
| ((None, _)) | ((_, [])) -> begin
def
end
| (Some (fvs), _38_1129) -> begin
(

let universes = (FStar_All.pipe_right univ_vars (FStar_List.map (fun _133_308 -> FStar_Syntax_Syntax.U_name (_133_308))))
in (

let inst = (FStar_All.pipe_right fvs (FStar_List.map (fun fv -> ((fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v), (universes)))))
in (FStar_Syntax_InstFV.instantiate inst def)))
end)
in (

let typ = (FStar_Syntax_Subst.close_univ_vars univ_vars typ)
in (

let def = (FStar_Syntax_Subst.close_univ_vars univ_vars def)
in (mk_letbinding lbname univ_vars typ eff def)))))


let open_univ_vars_binders_and_comp : FStar_Syntax_Syntax.univ_names  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.comp  ->  (FStar_Syntax_Syntax.univ_names * (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list * FStar_Syntax_Syntax.comp) = (fun uvs binders c -> (match (binders) with
| [] -> begin
(

let _38_1143 = (FStar_Syntax_Subst.open_univ_vars_comp uvs c)
in (match (_38_1143) with
| (uvs, c) -> begin
((uvs), ([]), (c))
end))
end
| _38_1145 -> begin
(

let t' = (arrow binders c)
in (

let _38_1149 = (FStar_Syntax_Subst.open_univ_vars uvs t')
in (match (_38_1149) with
| (uvs, t') -> begin
(match ((let _133_316 = (FStar_Syntax_Subst.compress t')
in _133_316.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (binders, c) -> begin
((uvs), (binders), (c))
end
| _38_1155 -> begin
(FStar_All.failwith "Impossible")
end)
end)))
end))


let is_tuple_constructor : FStar_Syntax_Syntax.typ  ->  Prims.bool = (fun t -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(FStar_Util.starts_with fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v.FStar_Ident.str "Prims.tuple")
end
| _38_1160 -> begin
false
end))


let mk_tuple_lid : Prims.int  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n r -> (

let t = (let _133_323 = (FStar_Util.string_of_int n)
in (FStar_Util.format1 "tuple%s" _133_323))
in (let _133_324 = (FStar_Syntax_Const.pconst t)
in (FStar_Ident.set_lid_range _133_324 r))))


let mk_tuple_data_lid : Prims.int  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n r -> (

let t = (let _133_329 = (FStar_Util.string_of_int n)
in (FStar_Util.format1 "Mktuple%s" _133_329))
in (let _133_330 = (FStar_Syntax_Const.pconst t)
in (FStar_Ident.set_lid_range _133_330 r))))


let is_tuple_data_lid : FStar_Ident.lident  ->  Prims.int  ->  Prims.bool = (fun f n -> (let _133_335 = (mk_tuple_data_lid n FStar_Range.dummyRange)
in (FStar_Ident.lid_equals f _133_335)))


let is_dtuple_constructor : FStar_Syntax_Syntax.typ  ->  Prims.bool = (fun t -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(FStar_Util.starts_with fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v.FStar_Ident.str "Prims.dtuple")
end
| _38_1173 -> begin
false
end))


let mk_dtuple_lid : Prims.int  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n r -> (

let t = (let _133_342 = (FStar_Util.string_of_int n)
in (FStar_Util.format1 "dtuple%s" _133_342))
in (let _133_343 = (FStar_Syntax_Const.pconst t)
in (FStar_Ident.set_lid_range _133_343 r))))


let mk_dtuple_data_lid : Prims.int  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n r -> (

let t = (let _133_348 = (FStar_Util.string_of_int n)
in (FStar_Util.format1 "Mkdtuple%s" _133_348))
in (let _133_349 = (FStar_Syntax_Const.pconst t)
in (FStar_Ident.set_lid_range _133_349 r))))


let is_lid_equality : FStar_Ident.lident  ->  Prims.bool = (fun x -> (FStar_Ident.lid_equals x FStar_Syntax_Const.eq2_lid))


let is_forall : FStar_Ident.lident  ->  Prims.bool = (fun lid -> (FStar_Ident.lid_equals lid FStar_Syntax_Const.forall_lid))


let is_exists : FStar_Ident.lident  ->  Prims.bool = (fun lid -> (FStar_Ident.lid_equals lid FStar_Syntax_Const.exists_lid))


let is_qlid : FStar_Ident.lident  ->  Prims.bool = (fun lid -> ((is_forall lid) || (is_exists lid)))


let is_equality = (fun x -> (is_lid_equality x.FStar_Syntax_Syntax.v))


let lid_is_connective : FStar_Ident.lident  ->  Prims.bool = (

let lst = (FStar_Syntax_Const.and_lid)::(FStar_Syntax_Const.or_lid)::(FStar_Syntax_Const.not_lid)::(FStar_Syntax_Const.iff_lid)::(FStar_Syntax_Const.imp_lid)::[]
in (fun lid -> (FStar_Util.for_some (FStar_Ident.lid_equals lid) lst)))


let is_constructor : FStar_Syntax_Syntax.term  ->  FStar_Ident.lident  ->  Prims.bool = (fun t lid -> (match ((let _133_365 = (pre_typ t)
in _133_365.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_fvar (tc) -> begin
(FStar_Ident.lid_equals tc.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v lid)
end
| _38_1192 -> begin
false
end))


let rec is_constructed_typ : FStar_Syntax_Syntax.term  ->  FStar_Ident.lident  ->  Prims.bool = (fun t lid -> (match ((let _133_370 = (pre_typ t)
in _133_370.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_fvar (_38_1196) -> begin
(is_constructor t lid)
end
| FStar_Syntax_Syntax.Tm_app (t, _38_1200) -> begin
(is_constructed_typ t lid)
end
| _38_1204 -> begin
false
end))


let rec get_tycon : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term Prims.option = (fun t -> (

let t = (pre_typ t)
in (match (t.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_name (_)) | (FStar_Syntax_Syntax.Tm_fvar (_)) -> begin
Some (t)
end
| FStar_Syntax_Syntax.Tm_app (t, _38_1218) -> begin
(get_tycon t)
end
| _38_1222 -> begin
None
end)))


let sortByFieldName = (fun fn_a_l -> (FStar_All.pipe_right fn_a_l (FStar_List.sortWith (fun _38_1228 _38_1232 -> (match (((_38_1228), (_38_1232))) with
| ((fn1, _38_1227), (fn2, _38_1231)) -> begin
(FStar_String.compare (FStar_Ident.text_of_lid fn1) (FStar_Ident.text_of_lid fn2))
end)))))


let is_interpreted : FStar_Ident.lident  ->  Prims.bool = (fun l -> (

let theory_syms = (FStar_Syntax_Const.op_Eq)::(FStar_Syntax_Const.op_notEq)::(FStar_Syntax_Const.op_LT)::(FStar_Syntax_Const.op_LTE)::(FStar_Syntax_Const.op_GT)::(FStar_Syntax_Const.op_GTE)::(FStar_Syntax_Const.op_Subtraction)::(FStar_Syntax_Const.op_Minus)::(FStar_Syntax_Const.op_Addition)::(FStar_Syntax_Const.op_Multiply)::(FStar_Syntax_Const.op_Division)::(FStar_Syntax_Const.op_Modulus)::(FStar_Syntax_Const.op_And)::(FStar_Syntax_Const.op_Or)::(FStar_Syntax_Const.op_Negation)::[]
in (FStar_Util.for_some (FStar_Ident.lid_equals l) theory_syms)))


let ktype : (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)) None FStar_Range.dummyRange)


let ktype0 : (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_zero)) None FStar_Range.dummyRange)


let type_u : Prims.unit  ->  (FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.universe) = (fun _38_1235 -> (match (()) with
| () -> begin
(

let u = (let _133_381 = (FStar_Unionfind.fresh None)
in (FStar_All.pipe_left (fun _133_380 -> FStar_Syntax_Syntax.U_unif (_133_380)) _133_381))
in (let _133_382 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (u)) None FStar_Range.dummyRange)
in ((_133_382), (u))))
end))


let kt_kt : (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (FStar_Syntax_Const.kunary ktype0 ktype0)


let kt_kt_kt : (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (FStar_Syntax_Const.kbin ktype0 ktype0 ktype0)


let fvar_const : FStar_Ident.lident  ->  FStar_Syntax_Syntax.term = (fun l -> (FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant None))


let tand : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.and_lid)


let tor : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.or_lid)


let timp : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.imp_lid)


let tiff : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.iff_lid)


let t_bool : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.bool_lid)


let t_false : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.false_lid)


let t_true : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.true_lid)


let b2t_v : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.b2t_lid)


let t_not : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.not_lid)


let mk_conj_opt : FStar_Syntax_Syntax.term Prims.option  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term Prims.option = (fun phi1 phi2 -> (match (phi1) with
| None -> begin
Some (phi2)
end
| Some (phi1) -> begin
(let _133_396 = (let _133_395 = (let _133_393 = (let _133_392 = (let _133_391 = (FStar_Syntax_Syntax.as_arg phi1)
in (let _133_390 = (let _133_389 = (FStar_Syntax_Syntax.as_arg phi2)
in (_133_389)::[])
in (_133_391)::_133_390))
in ((tand), (_133_392)))
in FStar_Syntax_Syntax.Tm_app (_133_393))
in (let _133_394 = (FStar_Range.union_ranges phi1.FStar_Syntax_Syntax.pos phi2.FStar_Syntax_Syntax.pos)
in (FStar_Syntax_Syntax.mk _133_395 None _133_394)))
in Some (_133_396))
end))


let mk_binop = (fun op_t phi1 phi2 -> (let _133_406 = (let _133_404 = (let _133_403 = (let _133_402 = (FStar_Syntax_Syntax.as_arg phi1)
in (let _133_401 = (let _133_400 = (FStar_Syntax_Syntax.as_arg phi2)
in (_133_400)::[])
in (_133_402)::_133_401))
in ((op_t), (_133_403)))
in FStar_Syntax_Syntax.Tm_app (_133_404))
in (let _133_405 = (FStar_Range.union_ranges phi1.FStar_Syntax_Syntax.pos phi2.FStar_Syntax_Syntax.pos)
in (FStar_Syntax_Syntax.mk _133_406 None _133_405))))


let mk_neg = (fun phi -> (let _133_411 = (let _133_410 = (let _133_409 = (let _133_408 = (FStar_Syntax_Syntax.as_arg phi)
in (_133_408)::[])
in ((t_not), (_133_409)))
in FStar_Syntax_Syntax.Tm_app (_133_410))
in (FStar_Syntax_Syntax.mk _133_411 None phi.FStar_Syntax_Syntax.pos)))


let mk_conj = (fun phi1 phi2 -> (mk_binop tand phi1 phi2))


let mk_conj_l : FStar_Syntax_Syntax.term Prims.list  ->  FStar_Syntax_Syntax.term = (fun phi -> (match (phi) with
| [] -> begin
(FStar_Syntax_Syntax.fvar FStar_Syntax_Const.true_lid FStar_Syntax_Syntax.Delta_constant None)
end
| (hd)::tl -> begin
(FStar_List.fold_right mk_conj tl hd)
end))


let mk_disj = (fun phi1 phi2 -> (mk_binop tor phi1 phi2))


let mk_disj_l : FStar_Syntax_Syntax.term Prims.list  ->  FStar_Syntax_Syntax.term = (fun phi -> (match (phi) with
| [] -> begin
t_false
end
| (hd)::tl -> begin
(FStar_List.fold_right mk_disj tl hd)
end))


let mk_imp : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun phi1 phi2 -> (match ((let _133_424 = (FStar_Syntax_Subst.compress phi1)
in _133_424.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_fvar (tc) when (FStar_Syntax_Syntax.fv_eq_lid tc FStar_Syntax_Const.false_lid) -> begin
t_true
end
| FStar_Syntax_Syntax.Tm_fvar (tc) when (FStar_Syntax_Syntax.fv_eq_lid tc FStar_Syntax_Const.true_lid) -> begin
phi2
end
| _38_1268 -> begin
(match ((let _133_425 = (FStar_Syntax_Subst.compress phi2)
in _133_425.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_fvar (tc) when ((FStar_Syntax_Syntax.fv_eq_lid tc FStar_Syntax_Const.true_lid) || (FStar_Syntax_Syntax.fv_eq_lid tc FStar_Syntax_Const.false_lid)) -> begin
phi2
end
| _38_1272 -> begin
(mk_binop timp phi1 phi2)
end)
end))


let mk_iff = (fun phi1 phi2 -> (mk_binop tiff phi1 phi2))


let b2t = (fun e -> (let _133_432 = (let _133_431 = (let _133_430 = (let _133_429 = (FStar_Syntax_Syntax.as_arg e)
in (_133_429)::[])
in ((b2t_v), (_133_430)))
in FStar_Syntax_Syntax.Tm_app (_133_431))
in (FStar_Syntax_Syntax.mk _133_432 None e.FStar_Syntax_Syntax.pos)))


let teq : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.eq2_lid)


let mk_eq = (fun t1 t2 e1 e2 -> (let _133_443 = (let _133_441 = (let _133_440 = (let _133_439 = (FStar_Syntax_Syntax.as_arg e1)
in (let _133_438 = (let _133_437 = (FStar_Syntax_Syntax.as_arg e2)
in (_133_437)::[])
in (_133_439)::_133_438))
in ((teq), (_133_440)))
in FStar_Syntax_Syntax.Tm_app (_133_441))
in (let _133_442 = (FStar_Range.union_ranges e1.FStar_Syntax_Syntax.pos e2.FStar_Syntax_Syntax.pos)
in (FStar_Syntax_Syntax.mk _133_443 None _133_442))))


let mk_has_type = (fun t x t' -> (

let t_has_type = (fvar_const FStar_Syntax_Const.has_type_lid)
in (

let t_has_type = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_uinst (((t_has_type), ((FStar_Syntax_Syntax.U_zero)::(FStar_Syntax_Syntax.U_zero)::[])))) None FStar_Range.dummyRange)
in (let _133_454 = (let _133_453 = (let _133_452 = (let _133_451 = (FStar_Syntax_Syntax.iarg t)
in (let _133_450 = (let _133_449 = (FStar_Syntax_Syntax.as_arg x)
in (let _133_448 = (let _133_447 = (FStar_Syntax_Syntax.as_arg t')
in (_133_447)::[])
in (_133_449)::_133_448))
in (_133_451)::_133_450))
in ((t_has_type), (_133_452)))
in FStar_Syntax_Syntax.Tm_app (_133_453))
in (FStar_Syntax_Syntax.mk _133_454 None FStar_Range.dummyRange)))))


let lex_t : FStar_Syntax_Syntax.term = (fvar_const FStar_Syntax_Const.lex_t_lid)


let lex_top : FStar_Syntax_Syntax.term = (FStar_Syntax_Syntax.fvar FStar_Syntax_Const.lextop_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))


let lex_pair : FStar_Syntax_Syntax.term = (FStar_Syntax_Syntax.fvar FStar_Syntax_Const.lexcons_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))


let tforall : FStar_Syntax_Syntax.term = (FStar_Syntax_Syntax.fvar FStar_Syntax_Const.forall_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))) None)


let t_haseq : FStar_Syntax_Syntax.term = (FStar_Syntax_Syntax.fvar FStar_Syntax_Const.haseq_lid FStar_Syntax_Syntax.Delta_constant None)


let lcomp_of_comp : (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax  ->  FStar_Syntax_Syntax.lcomp = (fun c0 -> (

let _38_1296 = (match (c0.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (_38_1287) -> begin
((FStar_Syntax_Const.effect_Tot_lid), ((FStar_Syntax_Syntax.TOTAL)::[]))
end
| FStar_Syntax_Syntax.GTotal (_38_1290) -> begin
((FStar_Syntax_Const.effect_GTot_lid), ((FStar_Syntax_Syntax.SOMETRIVIAL)::[]))
end
| FStar_Syntax_Syntax.Comp (c) -> begin
((c.FStar_Syntax_Syntax.effect_name), (c.FStar_Syntax_Syntax.flags))
end)
in (match (_38_1296) with
| (eff_name, flags) -> begin
{FStar_Syntax_Syntax.eff_name = eff_name; FStar_Syntax_Syntax.res_typ = (comp_result c0); FStar_Syntax_Syntax.cflags = flags; FStar_Syntax_Syntax.comp = (fun _38_1297 -> (match (()) with
| () -> begin
c0
end))}
end)))


let mk_forall : FStar_Syntax_Syntax.bv  ->  FStar_Syntax_Syntax.typ  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun x body -> (let _133_474 = (let _133_473 = (let _133_472 = (let _133_471 = (FStar_Syntax_Syntax.iarg x.FStar_Syntax_Syntax.sort)
in (let _133_470 = (let _133_469 = (let _133_468 = (let _133_467 = (let _133_462 = (FStar_Syntax_Syntax.mk_binder x)
in (_133_462)::[])
in (let _133_466 = (let _133_465 = (let _133_464 = (let _133_463 = (FStar_Syntax_Syntax.mk_Total ktype0)
in (FStar_All.pipe_left lcomp_of_comp _133_463))
in FStar_Util.Inl (_133_464))
in Some (_133_465))
in (abs _133_467 body _133_466)))
in (FStar_Syntax_Syntax.as_arg _133_468))
in (_133_469)::[])
in (_133_471)::_133_470))
in ((tforall), (_133_472)))
in FStar_Syntax_Syntax.Tm_app (_133_473))
in (FStar_Syntax_Syntax.mk _133_474 None FStar_Range.dummyRange)))


let rec close_forall : FStar_Syntax_Syntax.binder Prims.list  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.typ = (fun bs f -> (FStar_List.fold_right (fun b f -> if (FStar_Syntax_Syntax.is_null_binder b) then begin
f
end else begin
(mk_forall (Prims.fst b) f)
end) bs f))


let rec is_wild_pat = (fun p -> (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_wild (_38_1306) -> begin
true
end
| _38_1309 -> begin
false
end))


let if_then_else = (fun b t1 t2 -> (

let then_branch = (let _133_485 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t1.FStar_Syntax_Syntax.pos)
in ((_133_485), (None), (t1)))
in (

let else_branch = (let _133_486 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (false))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t2.FStar_Syntax_Syntax.pos)
in ((_133_486), (None), (t2)))
in (let _133_488 = (let _133_487 = (FStar_Range.union_ranges t1.FStar_Syntax_Syntax.pos t2.FStar_Syntax_Syntax.pos)
in (FStar_Range.union_ranges b.FStar_Syntax_Syntax.pos _133_487))
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (((b), ((then_branch)::(else_branch)::[])))) None _133_488)))))


type qpats =
FStar_Syntax_Syntax.args Prims.list


type connective =
| QAll of (FStar_Syntax_Syntax.binders * qpats * FStar_Syntax_Syntax.typ)
| QEx of (FStar_Syntax_Syntax.binders * qpats * FStar_Syntax_Syntax.typ)
| BaseConn of (FStar_Ident.lident * FStar_Syntax_Syntax.args)


let is_QAll = (fun _discr_ -> (match (_discr_) with
| QAll (_) -> begin
true
end
| _ -> begin
false
end))


let is_QEx = (fun _discr_ -> (match (_discr_) with
| QEx (_) -> begin
true
end
| _ -> begin
false
end))


let is_BaseConn = (fun _discr_ -> (match (_discr_) with
| BaseConn (_) -> begin
true
end
| _ -> begin
false
end))


let ___QAll____0 = (fun projectee -> (match (projectee) with
| QAll (_38_1317) -> begin
_38_1317
end))


let ___QEx____0 = (fun projectee -> (match (projectee) with
| QEx (_38_1320) -> begin
_38_1320
end))


let ___BaseConn____0 = (fun projectee -> (match (projectee) with
| BaseConn (_38_1323) -> begin
_38_1323
end))


let destruct_typ_as_formula : FStar_Syntax_Syntax.term  ->  connective Prims.option = (fun f -> (

let rec unmeta_monadic = (fun f -> (

let f = (FStar_Syntax_Subst.compress f)
in (match (f.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_monadic (_))) | (FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_monadic_lift (_))) -> begin
(unmeta_monadic t)
end
| _38_1340 -> begin
f
end)))
in (

let destruct_base_conn = (fun f -> (

let connectives = (((FStar_Syntax_Const.true_lid), ((Prims.parse_int "0"))))::(((FStar_Syntax_Const.false_lid), ((Prims.parse_int "0"))))::(((FStar_Syntax_Const.and_lid), ((Prims.parse_int "2"))))::(((FStar_Syntax_Const.or_lid), ((Prims.parse_int "2"))))::(((FStar_Syntax_Const.imp_lid), ((Prims.parse_int "2"))))::(((FStar_Syntax_Const.iff_lid), ((Prims.parse_int "2"))))::(((FStar_Syntax_Const.ite_lid), ((Prims.parse_int "3"))))::(((FStar_Syntax_Const.not_lid), ((Prims.parse_int "1"))))::(((FStar_Syntax_Const.eq2_lid), ((Prims.parse_int "3"))))::(((FStar_Syntax_Const.eq2_lid), ((Prims.parse_int "2"))))::(((FStar_Syntax_Const.eq3_lid), ((Prims.parse_int "4"))))::(((FStar_Syntax_Const.eq3_lid), ((Prims.parse_int "2"))))::[]
in (

let rec aux = (fun f _38_1348 -> (match (_38_1348) with
| (lid, arity) -> begin
(

let _38_1351 = (let _133_541 = (unmeta_monadic f)
in (head_and_args _133_541))
in (match (_38_1351) with
| (t, args) -> begin
(

let t = (un_uinst t)
in if ((is_constructor t lid) && ((FStar_List.length args) = arity)) then begin
Some (BaseConn (((lid), (args))))
end else begin
None
end)
end))
end))
in (FStar_Util.find_map connectives (aux f)))))
in (

let patterns = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_pattern (pats)) -> begin
(let _133_544 = (FStar_Syntax_Subst.compress t)
in ((pats), (_133_544)))
end
| _38_1362 -> begin
(let _133_545 = (FStar_Syntax_Subst.compress t)
in (([]), (_133_545)))
end)))
in (

let destruct_q_conn = (fun t -> (

let is_q = (fun fa fv -> if fa then begin
(is_forall fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end else begin
(is_exists fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end)
in (

let flat = (fun t -> (

let _38_1372 = (head_and_args t)
in (match (_38_1372) with
| (t, args) -> begin
(let _133_557 = (un_uinst t)
in (let _133_556 = (FStar_All.pipe_right args (FStar_List.map (fun _38_1375 -> (match (_38_1375) with
| (t, imp) -> begin
(let _133_555 = (unascribe t)
in ((_133_555), (imp)))
end))))
in ((_133_557), (_133_556))))
end)))
in (

let rec aux = (fun qopt out t -> (match ((let _133_564 = (flat t)
in ((qopt), (_133_564)))) with
| ((Some (fa), ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (tc); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, (({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_abs ((b)::[], t2, _); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, _))::[]))) | ((Some (fa), ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (tc); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, (_)::(({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_abs ((b)::[], t2, _); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, _))::[]))) when (is_q fa tc) -> begin
(aux qopt ((b)::out) t2)
end
| ((None, ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (tc); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, (({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_abs ((b)::[], t2, _); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, _))::[]))) | ((None, ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (tc); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, (_)::(({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_abs ((b)::[], t2, _); FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _; FStar_Syntax_Syntax.vars = _}, _))::[]))) when (is_qlid tc.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v) -> begin
(aux (Some ((is_forall tc.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v))) ((b)::out) t2)
end
| (Some (b), _38_1502) -> begin
(

let bs = (FStar_List.rev out)
in (

let _38_1507 = (FStar_Syntax_Subst.open_term bs t)
in (match (_38_1507) with
| (bs, t) -> begin
(

let _38_1510 = (patterns t)
in (match (_38_1510) with
| (pats, body) -> begin
if b then begin
Some (QAll (((bs), (pats), (body))))
end else begin
Some (QEx (((bs), (pats), (body))))
end
end))
end)))
end
| _38_1512 -> begin
None
end))
in (aux None [] t)))))
in (

let phi = (unmeta_monadic f)
in (match ((destruct_base_conn phi)) with
| Some (b) -> begin
Some (b)
end
| None -> begin
(destruct_q_conn phi)
end)))))))


let action_as_lb : FStar_Syntax_Syntax.action  ->  FStar_Syntax_Syntax.sigelt = (fun a -> (

let lb = (let _133_568 = (let _133_567 = (FStar_Syntax_Syntax.lid_as_fv a.FStar_Syntax_Syntax.action_name FStar_Syntax_Syntax.Delta_equational None)
in FStar_Util.Inr (_133_567))
in (close_univs_and_mk_letbinding None _133_568 a.FStar_Syntax_Syntax.action_univs a.FStar_Syntax_Syntax.action_typ FStar_Syntax_Const.effect_Tot_lid a.FStar_Syntax_Syntax.action_defn))
in FStar_Syntax_Syntax.Sig_let (((((false), ((lb)::[]))), (a.FStar_Syntax_Syntax.action_defn.FStar_Syntax_Syntax.pos), ((a.FStar_Syntax_Syntax.action_name)::[]), ([])))))


let mk_reify = (fun t -> (

let reify_ = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_reify)) None t.FStar_Syntax_Syntax.pos)
in (let _133_573 = (let _133_572 = (let _133_571 = (let _133_570 = (FStar_Syntax_Syntax.as_arg t)
in (_133_570)::[])
in ((reify_), (_133_571)))
in FStar_Syntax_Syntax.Tm_app (_133_572))
in (FStar_Syntax_Syntax.mk _133_573 None t.FStar_Syntax_Syntax.pos))))


let rec delta_qualifier : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.delta_depth = (fun t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_delayed (_38_1524) -> begin
(FStar_All.failwith "Impossible")
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv.FStar_Syntax_Syntax.fv_delta
end
| (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_name (_)) | (FStar_Syntax_Syntax.Tm_match (_)) | (FStar_Syntax_Syntax.Tm_uvar (_)) | (FStar_Syntax_Syntax.Tm_unknown) -> begin
FStar_Syntax_Syntax.Delta_equational
end
| (FStar_Syntax_Syntax.Tm_type (_)) | (FStar_Syntax_Syntax.Tm_constant (_)) | (FStar_Syntax_Syntax.Tm_arrow (_)) -> begin
FStar_Syntax_Syntax.Delta_constant
end
| (FStar_Syntax_Syntax.Tm_uinst (t, _)) | (FStar_Syntax_Syntax.Tm_refine ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}, _)) | (FStar_Syntax_Syntax.Tm_meta (t, _)) | (FStar_Syntax_Syntax.Tm_ascribed (t, _, _)) | (FStar_Syntax_Syntax.Tm_app (t, _)) | (FStar_Syntax_Syntax.Tm_abs (_, t, _)) | (FStar_Syntax_Syntax.Tm_let (_, t)) -> begin
(delta_qualifier t)
end)))


let incr_delta_qualifier : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.delta_depth = (fun t -> (

let d = (delta_qualifier t)
in (

let rec aux = (fun d -> (match (d) with
| FStar_Syntax_Syntax.Delta_equational -> begin
d
end
| FStar_Syntax_Syntax.Delta_constant -> begin
FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))
end
| FStar_Syntax_Syntax.Delta_defined_at_level (i) -> begin
FStar_Syntax_Syntax.Delta_defined_at_level ((i + (Prims.parse_int "1")))
end
| FStar_Syntax_Syntax.Delta_abstract (d) -> begin
(aux d)
end))
in (aux d))))


let is_unknown : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _133_585 = (FStar_Syntax_Subst.compress t)
in _133_585.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_unknown -> begin
true
end
| _38_1601 -> begin
false
end))


let rec list_elements : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term Prims.list Prims.option = (fun e -> (

let _38_1605 = (let _133_588 = (unmeta e)
in (head_and_args _133_588))
in (match (_38_1605) with
| (head, args) -> begin
(match ((let _133_590 = (let _133_589 = (un_uinst head)
in _133_589.FStar_Syntax_Syntax.n)
in ((_133_590), (args)))) with
| (FStar_Syntax_Syntax.Tm_fvar (fv), _38_1609) when (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.nil_lid) -> begin
Some ([])
end
| (FStar_Syntax_Syntax.Tm_fvar (fv), (_38_1622)::((hd, _38_1619))::((tl, _38_1615))::[]) when (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.cons_lid) -> begin
(let _133_593 = (let _133_592 = (let _133_591 = (list_elements tl)
in (FStar_Util.must _133_591))
in (hd)::_133_592)
in Some (_133_593))
end
| _38_1626 -> begin
None
end)
end)))




