module Steel.SelEffect

module Sem = Steel.Semantics.Hoare.MST
module Mem = Steel.Memory
module C = Steel.Effect.Common
open Steel.Semantics.Instantiate
module FExt = FStar.FunctionalExtensionality
module Eff = Steel.Effect

let hmem (p:vprop) = hmem (hp_of p)

let can_be_split (p q:vprop) : prop = Mem.slimp (hp_of p) (hp_of q)

(* Some properties about can_be_split that need to be exposed
   or derived from Steel.Effect.Common *)

let can_be_split_trans p q r = ()
let can_be_split_star_l p q = ()
let can_be_split_star_r p q = ()
let can_be_split_refl p = ()

let equiv p q = Mem.equiv (hp_of p) (hp_of q)

unfold
let unrestricted_mk_rmem (r:vprop) (h:hmem r) = fun (r0:vprop{r `can_be_split` r0}) -> normal (sel_of r0 h)

val mk_rmem (r:vprop) (h:hmem r) : Tot (rmem r)

let mk_rmem r h =
   FExt.on_dom_g
     (r0:vprop{r `can_be_split` r0})
     (unrestricted_mk_rmem r h)

let reveal_mk_rmem (r:vprop) (h:hmem r) (r0:vprop{r `can_be_split` r0})
  : Lemma ((mk_rmem r h) r0 == sel_of r0 h)
  = FExt.feq_on_domain_g (unrestricted_mk_rmem r h)

let rmem_depends_only_on' (pre:pre_t) (m0:hmem pre) (m1:mem{disjoint m0 m1})
  : Lemma (mk_rmem pre m0 == mk_rmem pre (join m0 m1))
  = Classical.forall_intro (reveal_mk_rmem pre m0);
    Classical.forall_intro (reveal_mk_rmem pre (join m0 m1));
    FExt.extensionality_g
      (r0:vprop{can_be_split pre r0})
      (fun r0 -> normal (t_of r0))
      (mk_rmem pre m0)
      (mk_rmem pre (join m0 m1))

let rmem_depends_only_on (pre:pre_t)
  : Lemma (forall (m0:hmem pre) (m1:mem{disjoint m0 m1}).
    mk_rmem pre m0 == mk_rmem pre (join m0 m1))
  = Classical.forall_intro_2 (rmem_depends_only_on' pre)

let rmem_depends_only_on_post' (#a:Type) (post:post_t a)
    (x:a) (m0:hmem (post x)) (m1:mem{disjoint m0 m1})
  : Lemma (mk_rmem (post x) m0 == mk_rmem (post x) (join m0 m1))
  = rmem_depends_only_on' (post x) m0 m1

let rmem_depends_only_on_post (#a:Type) (post:post_t a)
  : Lemma (forall (x:a) (m0:hmem (post x)) (m1:mem{disjoint m0 m1}).
    mk_rmem (post x) m0 == mk_rmem (post x) (join m0 m1))
  = Classical.forall_intro_3 (rmem_depends_only_on_post' post)

[@__steel_reduce__]
let req_to_act_req (#pre:pre_t) (req:req_t pre) : Sem.l_pre #state (hp_of pre) =
  rmem_depends_only_on pre;
  fun m0 -> interp (hp_of pre) m0 /\ req (mk_rmem pre m0)

unfold
let to_post (#a:Type) (post:post_t a) = fun x -> (hp_of (post x))

[@__steel_reduce__]
let ens_to_act_ens (#pre:pre_t) (#a:Type) (#post:post_t a) (ens:ens_t pre a post)
: Sem.l_post #state #a (hp_of pre) (to_post post)
= rmem_depends_only_on pre;
  rmem_depends_only_on_post post;
  fun m0 x m1 ->
    interp (hp_of pre) m0 /\ interp (hp_of (post x)) m1 /\ ens (mk_rmem pre m0) x (mk_rmem (post x) m1)

let reveal_focus_rmem (#r:vprop) (h:rmem r) (r0:vprop{r `can_be_split` r0}) (r':vprop{r0 `can_be_split` r'})
  : Lemma (
    r `can_be_split` r' /\
    focus_rmem h r0 r' == h r')
  = can_be_split_trans r r0 r';
    FExt.feq_on_domain_g (unrestricted_focus_rmem h r0)

let focus_is_restrict_mk_rmem (fp0 fp1:vprop) (m:hmem fp0)
  : Lemma
    (requires fp0 `can_be_split` fp1)
    (ensures focus_rmem (mk_rmem fp0 m) fp1 == mk_rmem fp1 m)
  = let f0:rmem fp0 = mk_rmem fp0 m in
    let f1:rmem fp1 = mk_rmem fp1 m in
    let f2:rmem fp1 = focus_rmem f0 fp1 in

    let aux (r:vprop{can_be_split fp1 r}) : Lemma (f1 r == f2 r)
      = can_be_split_trans fp0 fp1 r;

        reveal_mk_rmem fp0 m r;
        reveal_mk_rmem fp1 m r;
        reveal_focus_rmem f0 fp1 r
    in Classical.forall_intro aux;

    FExt.extensionality_g
      (r0:vprop{can_be_split fp1 r0})
      (fun r0 -> normal (t_of r0))
      (mk_rmem fp1 m)
      (focus_rmem (mk_rmem fp0 m) fp1)

let focus_focus_is_focus (fp0 fp1 fp2:vprop) (m:hmem fp0)
  : Lemma
    (requires fp0 `can_be_split` fp1 /\ fp1 `can_be_split` fp2)
    (ensures focus_rmem (focus_rmem (mk_rmem fp0 m) fp1) fp2 == focus_rmem (mk_rmem fp0 m) fp2)
  = let f0:rmem fp0 = mk_rmem fp0 m in
    let f1:rmem fp1 = focus_rmem f0 fp1 in
    let f20:rmem fp2 = focus_rmem f0 fp2 in
    let f21:rmem fp2 = focus_rmem f1 fp2 in

    let aux (r:vprop{can_be_split fp2 r}) : Lemma (f20 r == f21 r)
      = reveal_mk_rmem fp0 m r;
        reveal_focus_rmem f0 fp1 r;
        reveal_focus_rmem f0 fp2 r;
        reveal_focus_rmem f1 fp2 r

    in Classical.forall_intro aux;

    FExt.extensionality_g
      (r0:vprop{can_be_split fp2 r0})
      (fun r0 -> normal (t_of r0))
      f20 f21

val can_be_split_3_interp (p1 p2 q r:slprop u#1) (m:mem)
: Lemma
  (requires p1 `slimp` p2 /\  interp (p1 `Mem.star` q `Mem.star` r) m)
  (ensures interp (p2 `Mem.star` q `Mem.star` r) m)

let can_be_split_3_interp p1 p2 q r m =
  star_associative p1 q r;
  star_associative p2 q r;
  slimp_star p1 p2 (q `Mem.star` r) (q `Mem.star` r)

let repr (a:Type) (pre:pre_t) (post:post_t a) (req:req_t pre) (ens:ens_t pre a post) =
  Sem.action_t #state #a (hp_of pre) (to_post post)
    ((req_to_act_req req))
    ((ens_to_act_ens ens))

let nmst_get (#st:Sem.st) ()
  : Sem.Mst (Sem.full_mem st)
           (fun _ -> True)
           (fun s0 s s1 -> s0 == s /\ s == s1)
  = NMST.get ()

let rec lemma_frame_equalities_refl (frame:vprop) (h:rmem frame) : Lemma (frame_equalities frame h h) =
  match frame with
  | VUnit _ -> ()
  | VStar p1 p2 ->
        can_be_split_star_l p1 p2;
        can_be_split_star_r p1 p2;

        let h1 = focus_rmem h p1 in
        let h2 = focus_rmem h p2 in

        lemma_frame_equalities_refl p1 h1;
        lemma_frame_equalities_refl p2 h2

let return a x #p = fun _ ->
      let m0 = nmst_get () in
      let h0 = mk_rmem (p x) (core_mem m0) in
      lemma_frame_equalities_refl (p x) h0;
      x

#push-options "--fuel 0 --ifuel 0"

let norm_repr (#a:Type) (#pre:pre_t) (#post:post_t a) (#req:req_t pre) (#ens:ens_t pre a post)
 (f:repr a pre post req ens) : repr a pre post (fun h -> normal (req h)) (fun h0 x h1 -> normal (ens h0 x h1))
 = f


unfold
let bind_req_unnormal (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t)
  (req_g:(x:a -> req_t (pre_g x)))
  (_:squash (can_be_split_forall post_f pre_g))
  (m0:rmem pre_f)
= req_f m0 /\
  (forall (x:a) (m1:rmem (post_f x)). ens_f m0 x m1 ==> (req_g x) (focus_rmem m1 (pre_g x)))

unfold
let bind_ens_unnormal (#a:Type) (#b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (post:post_t b)
  (_:squash (can_be_split_forall post_f pre_g))
  (_:squash (can_be_split_post post_g post))
  (m0:rmem pre_f)
  (y:b)
  (m2:rmem (post y))
: prop
= req_f m0 /\
  (exists (x:a) (m1:rmem (post_f x)). ens_f m0 x m1 /\ (ens_g x) (focus_rmem m1 (pre_g x)) y (focus_rmem m2 (post_g x y)))

val bind_aux (a:Type) (b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (#req_f:req_t pre_f) (#ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (#req_g:(x:a -> req_t (pre_g x))) (#ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (#post:post_t b)
  (#p1:squash (can_be_split_forall post_f pre_g))
  (#p2:squash (can_be_split_post post_g post))
  (f:repr a pre_f post_f req_f ens_f)
  (g:(x:a -> repr b (pre_g x) (post_g x) (req_g x) (ens_g x)))
: repr b
    pre_f
    post
    (bind_req_unnormal req_f ens_f req_g p1)
    (bind_ens_unnormal req_f ens_f ens_g post p1 p2)

let bind_aux a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #post #p1 #p2 f g =
fun frame ->
  let x = f frame in
  let m1 = nmst_get () in

  focus_is_restrict_mk_rmem (post_f x) (pre_g x) (core_mem m1);
  can_be_split_3_interp (hp_of (post_f x)) (hp_of (pre_g x)) frame (locks_invariant Set.empty m1) m1;


  let y = g x frame in

  let m2 = nmst_get () in

  focus_is_restrict_mk_rmem (post y) (post_g x y) (core_mem m2);


  can_be_split_3_interp (hp_of (post_g x y)) (hp_of (post y)) frame (locks_invariant Set.empty m2) m2;

  y


let bind a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #post #p1 #p2 f g =
  norm_repr (bind_aux a b f g)

unfold
let subcomp_pre_unnormal (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a) (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:pre_t) (#post_g:post_t a) (req_g:req_t pre_g) (ens_g:ens_t pre_g a post_g)
  (_:squash (can_be_split pre_g pre_f))
  (_:squash (equiv_forall post_f post_g))
: pure_pre
= ((forall (m0:rmem pre_g). req_g m0 ==> req_f (focus_rmem m0 pre_f)) /\
  (forall (m0:rmem pre_g) (x:a) (m1:rmem (post_g x)). ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) ==> ens_g m0 x m1))

let unnormal (p:prop) : Lemma (requires normal p) (ensures p) = ()

let subcomp a #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #p1 #p2 f =
  fun frame ->
    let m0 = nmst_get () in
    let h0 = mk_rmem pre_g (core_mem m0) in
    focus_is_restrict_mk_rmem pre_g pre_f (core_mem m0);

    can_be_split_3_interp (hp_of pre_g) (hp_of pre_f) frame (locks_invariant Set.empty m0) m0;

    let x = f frame in


    let m1 = nmst_get () in
    let h1 = mk_rmem (post_g x) (core_mem m1) in

    focus_is_restrict_mk_rmem (post_g x) (post_f x) (core_mem m1);

    unnormal (subcomp_pre_unnormal req_f ens_f req_g ens_g p1 p2);


    can_be_split_3_interp (hp_of (post_f x)) (hp_of (post_g x)) frame (locks_invariant Set.empty m1) m1;

    x

val req_frame (frame:vprop) (snap:rmem frame) : mprop (hp_of frame)

let req_frame' (frame:vprop) (snap:rmem frame) (m:mem) : prop =
  interp (hp_of frame) m /\ mk_rmem frame m == snap

let req_frame frame snap =
  rmem_depends_only_on frame;
  req_frame' frame snap

#push-options "--z3rlimit 20 --fuel 1 --ifuel 1"

val frame00 (#a:Type)
          (#pre:pre_t)
          (#post:post_t a)
          (#req:req_t pre)
          (#ens:ens_t pre a post)
          ($f:repr a pre post req ens)
          (frame:vprop)
  : repr a
    (pre `star` frame)
    (fun x -> post x `star` frame)
    (fun h -> req (focus_rmem h pre))
    (fun h0 r h1 -> req (focus_rmem h0 pre) /\ ens (focus_rmem h0 pre) r (focus_rmem h1 (post r)) /\
     frame_equalities frame (focus_rmem h0 frame) (focus_rmem h1 frame))

let frame00 #a #pre #post #req #ens f frame =
  fun frame' ->
      let m0 = nmst_get () in

      let snap:rmem frame = mk_rmem frame (core_mem m0) in

      focus_is_restrict_mk_rmem (pre `star` frame) pre (core_mem m0);

      let x = Sem.run #state #_ #_ #_ #_ #_ frame' (Sem.Frame (Sem.Act f) (hp_of frame) (req_frame frame snap)) in

      let m1 = nmst_get () in

      can_be_split_star_r pre frame;
      focus_is_restrict_mk_rmem (pre `star` frame) frame (core_mem m0);
      can_be_split_star_r (post x) frame;
      focus_is_restrict_mk_rmem (post x `star` frame) frame (core_mem m1);

      focus_is_restrict_mk_rmem (post x `star` frame) (post x) (core_mem m1);

      // We proved focus_rmem h0 frame == focus_rmem h1 frame so far

      let h0:rmem (pre `star` frame) = mk_rmem (pre `star` frame) (core_mem m0) in
      lemma_frame_equalities_refl frame (focus_rmem h0 frame);

      x

#pop-options

unfold
let bind_steel_steel_req_unnormal (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t)
  (req_g:(x:a -> req_t (pre_g x)))
  (frame_f:vprop) (frame_g:a -> vprop)
  (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) (fun x -> pre_g x `star` frame_g x)))
  (m0:rmem (pre_f `star` frame_f))
= req_f (focus_rmem m0 pre_f) /\
  (forall (x:a) (m1:rmem (post_f x `star` frame_f)). (
    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (pre_g x);
    (ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) /\
      frame_equalities frame_f (focus_rmem m0 frame_f) (focus_rmem m1 frame_f))
    ==>
      (req_g x) (focus_rmem m1 (pre_g x))))

unfold
let bind_steel_steel_ens_unnormal (#a:Type) (#b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (frame_f:vprop) (frame_g:a -> vprop)
  (post:post_t b)
  (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) (fun x -> pre_g x `star` frame_g x)))
  (_:squash (can_be_split_post (fun x y -> post_g x y `star` frame_g x) post))
  (m0:rmem (pre_f `star` frame_f))
  (y:b)
  (m2:rmem (post y))
= req_f (focus_rmem m0 pre_f) /\
  (exists (x:a) (m1:rmem (post_f x `star` frame_f)). (
    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (pre_g x);
    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (frame_g x);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (post_g x y);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (frame_g x);
    frame_equalities frame_f (focus_rmem m0 frame_f) (focus_rmem m1 frame_f) /\
    frame_equalities (frame_g x) (focus_rmem m1 (frame_g x)) (focus_rmem m2 (frame_g x)) /\
    ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) /\
    (ens_g x) (focus_rmem m1 (pre_g x)) y (focus_rmem m2 (post_g x y))))

val bind_steel_steel_aux (a:Type) (b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (#req_f:req_t pre_f) (#ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (#req_g:(x:a -> req_t (pre_g x))) (#ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (#frame_f:vprop) (#frame_g:a -> vprop)
  (#post:post_t b)
  (#p:squash (can_be_split_forall
    (fun x -> post_f x `star` frame_f) (fun x -> pre_g x `star` frame_g x)))
  (#p2:squash (can_be_split_post (fun x y -> post_g x y `star` frame_g x) post))
  (f:repr a pre_f post_f req_f ens_f)
  (g:(x:a -> repr b (pre_g x) (post_g x) (req_g x) (ens_g x)))
: repr b
    (pre_f `star` frame_f)
    post
    (bind_steel_steel_req_unnormal req_f ens_f req_g frame_f frame_g p)
    (bind_steel_steel_ens_unnormal req_f ens_f ens_g frame_f frame_g post p p2)

#push-options "--z3rlimit 20"
let bind_steel_steel_aux a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #frame_f #frame_g #post #p #p2 f g =
  fun frame ->
    let m0 = nmst_get () in

    let h0 = mk_rmem (pre_f `star` frame_f) (core_mem m0) in

    let x = frame00 f frame_f frame  in

    let m1 = nmst_get () in

    let h1 = mk_rmem (post_f x `star` frame_f) (core_mem m1) in

    let h1' = mk_rmem (pre_g x `star` frame_g x) (core_mem m1) in

    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (pre_g x);
    focus_is_restrict_mk_rmem
      (post_f x `star` frame_f)
      (pre_g x `star` frame_g x)
      (core_mem m1);
    focus_focus_is_focus
      (post_f x `star` frame_f)
      (pre_g x `star` frame_g x)
      (pre_g x)
      (core_mem m1);
    assert (focus_rmem h1' (pre_g x) == focus_rmem h1 (pre_g x));

    can_be_split_3_interp
      (hp_of (post_f x `star` frame_f))
      (hp_of (pre_g x `star` frame_g x))
      frame (locks_invariant Set.empty m1) m1;

    let y = frame00 (g x) (frame_g x) frame in

    let m2 = nmst_get () in

    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (pre_g x);
    can_be_split_trans (post_f x `star` frame_f) (pre_g x `star` frame_g x) (frame_g x);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (post_g x y);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (frame_g x);

    let h2' = mk_rmem (post_g x y `star` frame_g x) (core_mem m2) in
    let h2 = mk_rmem (post y) (core_mem m2) in



    // assert (focus_rmem h1' (pre_g x) == focus_rmem h1 (pre_g x));

    focus_focus_is_focus
      (post_f x `star` frame_f)
      (pre_g x `star` frame_g x)
      (frame_g x)
      (core_mem m1);

    focus_is_restrict_mk_rmem
      (post_g x y `star` frame_g x)
      (post y)
      (core_mem m2);

    focus_focus_is_focus
      (post_g x y `star` frame_g x)
      (post y)
      (frame_g x)
      (core_mem m2);
    focus_focus_is_focus
      (post_g x y `star` frame_g x)
      (post y)
      (post_g x y)
      (core_mem m2);

    can_be_split_3_interp
      (hp_of (post_g x y `star` frame_g x))
      (hp_of (post y))
      frame (locks_invariant Set.empty m2) m2;


    y

#pop-options

let bind_steel_steel a b f g =
  norm_repr (bind_steel_steel_aux a b f g)

unfold
let bind_steel_steelf_req_unnormal (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t)
  (req_g:(x:a -> req_t (pre_g x)))
  (frame_f:vprop)
  (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
  (m0:rmem (pre_f `star` frame_f))
= req_f (focus_rmem m0 pre_f) /\
  (forall (x:a) (m1:rmem (post_f x `star` frame_f)).
    (ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) /\ frame_equalities frame_f (focus_rmem m0 frame_f) (focus_rmem m1 frame_f)) ==>
      (req_g x) (focus_rmem m1 (pre_g x)))

unfold
let bind_steel_steelf_ens_unnormal (#a:Type) (#b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (frame_f:vprop)
  (post:post_t b)
  (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
  (_: squash (can_be_split_post post_g post))
  (m0:rmem (pre_f `star` frame_f))
  (y:b)
  (m2:rmem (post y))
= req_f (focus_rmem m0 pre_f) /\
  (exists (x:a) (m1:rmem (post_f x `star` frame_f)). (
    frame_equalities frame_f (focus_rmem m0 frame_f) (focus_rmem m1 frame_f)) /\
    ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) /\ (ens_g x) (focus_rmem m1 (pre_g x)) y (focus_rmem m2 (post_g x y)))

val bind_steel_steelf_aux (a:Type) (b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (#req_f:req_t pre_f) (#ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (#req_g:(x:a -> req_t (pre_g x))) (#ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (#frame_f:vprop)
  (#post:post_t b)
  (#p:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
  (#p2: squash (can_be_split_post post_g post))
  (f:repr a pre_f post_f req_f ens_f)
  (g:(x:a -> repr b (pre_g x) (post_g x) (req_g x) (ens_g x)))
: repr b
    (pre_f `star` frame_f)
    post
    (bind_steel_steelf_req_unnormal req_f ens_f req_g frame_f p)
    (bind_steel_steelf_ens_unnormal req_f ens_f ens_g frame_f post p p2)

let bind_steel_steelf_aux a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #frame_f #post #p #p2 f g =
  fun frame ->

    let x = frame00 f frame_f frame in
    let m1 = nmst_get () in

    can_be_split_3_interp
      (hp_of (post_f x `star` frame_f))
      (hp_of (pre_g x))
      frame (locks_invariant Set.empty m1) m1;

    focus_is_restrict_mk_rmem
      (post_f x `star` frame_f)
      (pre_g x)
      (core_mem m1);

    let y = g x frame in

    let m2 = nmst_get () in

    focus_is_restrict_mk_rmem (post y) (post_g x y) (core_mem m2);


    can_be_split_3_interp (hp_of (post_g x y)) (hp_of (post y)) frame (locks_invariant Set.empty m2) m2;

    y

let bind_steel_steelf a b f g = norm_repr (bind_steel_steelf_aux a b f g)

unfold
let bind_steelf_steel_req_unnormal (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t)
  (req_g:(x:a -> req_t (pre_g x)))
  (frame_g:a -> vprop)
  (_:squash (can_be_split_forall post_f (fun x -> pre_g x `star` frame_g x)))
  (m0:rmem pre_f)
= req_f m0 /\
  (forall (x:a) (m1:rmem (post_f x)). (
    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (pre_g x);
    ens_f m0 x m1 ==> (req_g x) (focus_rmem m1 (pre_g x))))

unfold
let bind_steelf_steel_ens_unnormal (#a:Type) (#b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (frame_g:a -> vprop)
  (post:post_t b)
  (_:squash (can_be_split_forall post_f (fun x -> pre_g x `star` frame_g x)))
  (_:squash (can_be_split_post (fun x y -> post_g x y `star` frame_g x) post))
  (m0:rmem pre_f)
  (y:b)
  (m2:rmem (post y))
= req_f m0 /\
  (exists (x:a) (m1:rmem (post_f x)). (
    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (pre_g x);
    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (frame_g x);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (post_g x y);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (frame_g x);
    frame_equalities (frame_g x) (focus_rmem m1 (frame_g x)) (focus_rmem m2 (frame_g x)) /\
    ens_f m0 x m1 /\ (ens_g x) (focus_rmem m1 (pre_g x)) y (focus_rmem m2 (post_g x y))))

val bind_steelf_steel_aux (a:Type) (b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (#req_f:req_t pre_f) (#ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:a -> post_t b)
  (#req_g:(x:a -> req_t (pre_g x))) (#ens_g:(x:a -> ens_t (pre_g x) b (post_g x)))
  (#frame_g:a -> vprop)
  (#post:post_t b)
  (#p:squash (can_be_split_forall post_f (fun x -> pre_g x `star` frame_g x)))
  (#p2:squash (can_be_split_post (fun x y -> post_g x y `star` frame_g x) post))
  (f:repr a pre_f post_f req_f ens_f)
  (g:(x:a -> repr b (pre_g x) (post_g x) (req_g x) (ens_g x)))
: repr b
    pre_f
    post
    (bind_steelf_steel_req_unnormal req_f ens_f req_g frame_g p)
    (bind_steelf_steel_ens_unnormal req_f ens_f ens_g frame_g post p p2)

#push-options "--z3rlimit 20"
let bind_steelf_steel_aux a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #frame_g #post #p #p2 f g =
  fun frame ->
    let x = f frame in
    let m1 = nmst_get () in

    let h1 = mk_rmem (post_f x) (core_mem m1) in

    let h1' = mk_rmem (pre_g x `star` frame_g x) (core_mem m1) in

    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (pre_g x);
    focus_is_restrict_mk_rmem
      (post_f x)
      (pre_g x `star` frame_g x)
      (core_mem m1);
    focus_focus_is_focus
      (post_f x)
      (pre_g x `star` frame_g x)
      (pre_g x)
      (core_mem m1);
    assert (focus_rmem h1' (pre_g x) == focus_rmem h1 (pre_g x));

    can_be_split_3_interp
      (hp_of (post_f x))
      (hp_of (pre_g x `star` frame_g x))
      frame (locks_invariant Set.empty m1) m1;

    let y = frame00 (g x) (frame_g x) frame in

    let m2 = nmst_get () in

    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (pre_g x);
    can_be_split_trans (post_f x) (pre_g x `star` frame_g x) (frame_g x);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (post_g x y);
    can_be_split_trans (post y) (post_g x y `star` frame_g x) (frame_g x);


    focus_focus_is_focus
      (post_f x)
      (pre_g x `star` frame_g x)
      (frame_g x)
      (core_mem m1);

    focus_is_restrict_mk_rmem
      (post_g x y `star` frame_g x)
      (post y)
      (core_mem m2);

    focus_focus_is_focus
      (post_g x y `star` frame_g x)
      (post y)
      (frame_g x)
      (core_mem m2);
    focus_focus_is_focus
      (post_g x y `star` frame_g x)
      (post y)
      (post_g x y)
      (core_mem m2);

    can_be_split_3_interp
      (hp_of (post_g x y `star` frame_g x))
      (hp_of (post y))
      frame (locks_invariant Set.empty m2) m2;


    y
#pop-options

let bind_steelf_steel a b f g = norm_repr (bind_steelf_steel_aux a b f g)

let bind_pure_steel_ a b wp #pre #post #req #ens f g
  = FStar.Monotonic.Pure.wp_monotonic_pure ();
    fun frame ->
      let x = f () in
      g x frame

let vemp':vprop' =
  { hp = emp;
    t = unit;
    sel = fun _ -> ()}
let vemp = VUnit vemp'

(* Simple Reference library, only full permissions.
   AF: Permissions would likely need to be an index of the vprop ptr.
   It cannot be part of a selector, as it is not invariant when joining with a disjoint memory
   Using the value of the ref as a selector is ok because refs with fractional permissions
   all share the same value.
   Refs on PCM are more complicated, and likely not usable with selectors
*)

module R = Steel.Reference
open Steel.FractionalPermission

let ref a = R.ref a

let ptr r = h_exists (R.pts_to r full_perm)

val ptr_sel' (#a:Type0) (r: ref a) : selector' a (ptr r)
let ptr_sel' #a r = fun h ->
  let x = id_elim_exists #(erased a) (R.pts_to r full_perm) h in
  reveal (reveal x)

let ptr_sel_depends_only_on (#a:Type0) (r:ref a)
  (m0:Mem.hmem (ptr r)) (m1:mem{disjoint m0 m1})
  : Lemma (ptr_sel' r m0 == ptr_sel' r (join m0 m1))
  = let x = reveal (id_elim_exists #(erased a) (R.pts_to r full_perm) m0) in
    let y = reveal (id_elim_exists #(erased a) (R.pts_to r full_perm) (join m0 m1)) in
    R.pts_to_witinv r full_perm;
    elim_wi (R.pts_to r full_perm) x y (join m0 m1)

let ptr_sel_depends_only_on_core (#a:Type0) (r:ref a)
  (m0:Mem.hmem (ptr r))
  : Lemma (ptr_sel' r m0 == ptr_sel' r (core_mem m0))
  = let x = reveal (id_elim_exists #(erased a) (R.pts_to r full_perm) m0) in
    let y = reveal (id_elim_exists #(erased a) (R.pts_to r full_perm) (core_mem m0)) in
    R.pts_to_witinv r full_perm;
    elim_wi (R.pts_to r full_perm) x y (core_mem m0)


let ptr_sel r =
  Classical.forall_intro_2 (ptr_sel_depends_only_on r);
  Classical.forall_intro (ptr_sel_depends_only_on_core r);
  ptr_sel' r

friend Steel.Effect

let as_steelsel0 (#a:Type)
  (#pre:pre_t) (#post:post_t a)
  (#req:prop) (#ens:a -> prop)
  (f:Eff.repr a (hp_of pre) (fun x -> hp_of (post x)) (fun h -> req) (fun _ x _ -> ens x))
: repr a pre post (fun _ -> req) (fun _ x _ -> ens x)
  = fun frame -> f frame


let as_steelsel1 (#a:Type)
  (#pre:pre_t) (#post:post_t a)
  (#req:prop) (#ens:a -> prop)
  (f:Eff.repr a (hp_of pre) (fun x -> hp_of (post x)) (fun h -> req) (fun _ x _ -> ens x))
: SteelSel a pre post (fun _ -> req) (fun _ x _ -> ens x)
  = SteelSel?.reflect (as_steelsel0 f)

let as_steelsel (#a:Type)
  (#pre:pre_t) (#post:post_t a)
  (#req:prop) (#ens:a -> prop)
  ($f:unit -> Eff.Steel a (hp_of pre) (fun x -> hp_of (post x)) (fun h -> req) (fun _ x _ -> ens x))
: SteelSel a pre post (fun _ -> req) (fun _ x _ -> ens x)
  = as_steelsel1 (reify (f ()))

let vptr_tmp' (#a:Type) (r:ref a) (p:perm) (v:erased a) : vprop' =
  { hp = R.pts_to r p v;
    t = unit;
    sel = fun _ -> ()}
let vptr_tmp r p v : vprop = VUnit (vptr_tmp' r p v)

val alloc0 (#a:Type0) (x:a) : SteelSel (ref a)
  vemp (fun r -> vptr_tmp r full_perm x)
  (requires fun _ -> True)
  (ensures fun _ r h1 -> True)

let alloc0 x = as_steelsel (fun _ -> R.alloc x)

let intro_vptr (#a:Type) (r:ref a) (v:erased a) (m:mem) : Lemma
  (requires interp (hp_of (vptr_tmp r full_perm v)) m)
  (ensures interp (hp_of (vptr r)) m /\ sel_of (vptr r) m == reveal v)
  = Mem.intro_h_exists v (R.pts_to r full_perm) m;
    R.pts_to_witinv r full_perm

let elim_vptr (#a:Type) (r:ref a) (v:erased a) (m:mem) : Lemma
  (requires interp (hp_of (vptr r)) m /\ sel_of (vptr r) m == reveal v)
  (ensures interp (hp_of (vptr_tmp r full_perm v)) m)
  = Mem.elim_h_exists (R.pts_to r full_perm) m;
    R.pts_to_witinv r full_perm

let alloc x =
  let r = alloc0 x in
  change_slprop (vptr_tmp r full_perm x) (vptr r) () x (intro_vptr r x);
  returnc r

val read0 (#a:Type0) (r:ref a) (v:erased a) : SteelSel a
  (vptr_tmp r full_perm v) (fun x -> vptr_tmp r full_perm x)
  (requires fun _ -> True)
  (ensures fun h0 x h1 -> x == reveal v)

let read0 #a r v = as_steelsel (fun _ -> R.read #a #full_perm #v r)

let read (#a:Type0) (r:ref a) : SteelSel a
  (vptr r) (fun _ -> vptr r)
  (requires fun _ -> True)
  (ensures fun h0 x h1 -> h0 (vptr r) == h1 (vptr r) /\ x == h1 (vptr r))
  = let h0 = get() in
    let v = hide (h0 (vptr r)) in
    change_slprop (vptr r) (vptr_tmp r full_perm v) v () (elim_vptr r v);
    let x = read0 r v in
    change_slprop (vptr_tmp r full_perm x) (vptr r) () x (intro_vptr r x);
    returnc x

val write0 (#a:Type0) (v:erased a) (r:ref a) (x:a)
  : SteelSel unit
    (vptr_tmp r full_perm v) (fun _ -> vptr_tmp r full_perm x)
    (fun _ -> True) (fun _ _ _ -> True)

let write0 #a v r x = as_steelsel (fun _ -> R.write #a #v r x)

let write (#a:Type0) (r:ref a) (x:a) : SteelSel unit
  (vptr r) (fun _ -> vptr r)
  (requires fun _ -> True)
  (ensures fun _ _ h1 -> x == h1 (vptr r))
  = let h0 = get() in
    let v = hide (h0 (vptr r)) in
    change_slprop (vptr r) (vptr_tmp r full_perm v) v () (elim_vptr r v);
    write0 v r x;
    change_slprop (vptr_tmp r full_perm x) (vptr r) () x (intro_vptr r x)


(*
let subcomp a pre post req_f ens_f req_g ens_g f = f

let bind_pure_steel a b wp pre_g post_b req_g ens_g f g
  = FStar.Monotonic.Pure.wp_monotonic_pure ();
    fun frame ->
      let x = f () in
      g x frame

(* We need a bind with DIV to implement frame/par, using reification *)

unfold
let bind_div_steel_req (#a:Type) (wp:pure_wp a)
  (#pre_g:pre_t) (req_g:a -> req_t pre_g)
: req_t pre_g
= FStar.Monotonic.Pure.wp_monotonic_pure ();
  fun h -> wp (fun _ -> True) /\ (forall x. (req_g x) h)

unfold
let bind_div_steel_ens (#a:Type) (#b:Type)
  (wp:pure_wp a)
  (#pre_g:pre_t) (#post_g:post_t b) (ens_g:a -> ens_t pre_g b post_g)
: ens_t pre_g b post_g
= fun h0 r h1 -> wp (fun _ -> True) /\ (exists x. ens_g x h0 r h1)

#push-options "--z3rlimit 20 --fuel 2 --ifuel 1"
let bind_div_steel (a:Type) (b:Type)
  (wp:pure_wp a)
  (pre_g:pre_t) (post_g:post_t b) (req_g:a -> req_t pre_g) (ens_g:a -> ens_t pre_g b post_g)
  (f:eqtype_as_type unit -> DIV a wp) (g:(x:a -> repr b pre_g post_g (req_g x) (ens_g x)))
: repr b pre_g post_g
    (bind_div_steel_req wp req_g)
    (bind_div_steel_ens wp ens_g)
= FStar.Monotonic.Pure.wp_monotonic_pure ();
  fun frame ->
  let x = f () in
  g x frame
#pop-options

polymonadic_bind (DIV, SteelSel) |> SteelSel = bind_div_steel


let returnc0 (#a:Type) (#p:a -> vprop) (x:a)
  : repr a (p x) p (fun _ -> True) (fun h0 r h1 -> r == x /\ normal (frame_equalities (p x) h0 h1))
  = fun frame ->
      let m0 = nmst_get () in
      let h0 = mk_rmem (p x) (core_mem m0) in
      lemma_frame_equalities_refl (p x) h0;
      x

let returnc (#a:Type) (#p:a -> vprop) (x:a)
  : SteelSel a (p x) p (fun _ -> True) (fun h0 r h1 -> r == x /\ normal (frame_equalities (p x) h0 h1))
  = SteelSel?.reflect (returnc0 #a #p x)


let get0 (#p:vprop) (_:unit) : repr (rmem p)
  p (fun _ -> p)
  (requires fun _ -> True)
  (ensures fun h0 r h1 -> normal (frame_equalities p h0 h1 /\ frame_equalities p r h1))
  = fun frame ->
      let m0 = nmst_get () in
      let h0 = mk_rmem p (core_mem m0) in
      lemma_frame_equalities_refl p h0;
      h0

let get #r _ = SteelSel?.reflect (get0 #r ())


let intro_star (p q:vprop) (r:slprop) (vp:erased (t_of p)) (vq:erased (t_of q)) (m:mem)
  (proof:(m:mem) -> Lemma
    (requires interp (hp_of p) m /\ sel_of p m == reveal vp)
    (ensures interp (hp_of q) m /\ sel_of q m == reveal vq)
  )
  : Lemma
   (requires interp ((hp_of p) `Mem.star` r) m /\ sel_of p m == reveal vp)
   (ensures interp ((hp_of q) `Mem.star` r) m)
= let p = hp_of p in
  let q = hp_of q in
  let intro (ml mr:mem) : Lemma
      (requires interp q ml /\ interp r mr /\ disjoint ml mr)
      (ensures disjoint ml mr /\ interp (q `Mem.star` r) (join ml mr))
  = intro_star q r ml mr
  in
  elim_star p r m;
  Classical.forall_intro (Classical.move_requires proof);
  Classical.forall_intro_2 (Classical.move_requires_2 intro)

#push-options "--z3rlimit 20 --fuel 1 --ifuel 0"
let change_slprop0 (p q:vprop) (vp:erased (t_of p)) (vq:erased (t_of q))
  (proof:(m:mem) -> Lemma
    (requires interp (hp_of p) m /\ sel_of p m == reveal vp)
    (ensures interp (hp_of q) m /\ sel_of q m == reveal vq)
  ) : repr unit p (fun _ -> q) (fun h -> h p == reveal vp) (fun _ _ h1 -> h1 q == reveal vq)
  = fun frame ->
      let m = nmst_get () in
      proof (core_mem m);
      Classical.forall_intro (Classical.move_requires proof);
      intro_star p q (frame `Mem.star` locks_invariant Set.empty m) vp vq m proof
#pop-options

let change_slprop (p q:vprop) (vp:erased (t_of p)) (vq:erased (t_of q))
  (l:(m:mem) -> Lemma
    (requires interp (hp_of p) m /\ sel_of p m == reveal vp)
    (ensures interp (hp_of q) m /\ sel_of q m == reveal vq)
  ) : SteelSel unit p (fun _ -> q) (fun h -> h p == reveal vp) (fun _ _ h1 -> h1 q == reveal vq)
  = SteelSel?.reflect (change_slprop0 p q vp vq l)

let respects_fp (#fp:vprop) (p:hmem fp -> prop) : prop =
  forall (m0:hmem fp) (m1:mem{disjoint m0 m1}). p m0 <==> p (join m0 m1)

let fp_mprop (fp:vprop) = p:(hmem fp -> prop) { respects_fp #fp p }

val req_frame (frame:vprop) (snap:rmem frame) : mprop (hp_of frame)

let req_frame' (frame:vprop) (snap:rmem frame) (m:mem) : prop =
  interp (hp_of frame) m /\ mk_rmem frame m == snap

let req_frame frame snap =
  rmem_depends_only_on frame;
  req_frame' frame snap

#push-options "--z3rlimit 20"
let frame00 (#a:Type)
          (#pre:pre_t)
          (#post:post_t a)
          (#req:req_t pre)
          (#ens:ens_t pre a post)
          (f:repr a pre post req ens)
          (frame:vprop)
  : repr a
    (pre `star` frame)
    (fun x -> post x `star` frame)
    (fun h -> req (focus_rmem h pre))
    (fun h0 r h1 -> req (focus_rmem h0 pre) /\ ens (focus_rmem h0 pre) r (focus_rmem h1 (post r)) /\
     frame_equalities frame (focus_rmem h0 frame) (focus_rmem h1 frame))
  = fun frame' ->
      let m0 = nmst_get () in

      let snap:rmem frame = mk_rmem frame (core_mem m0) in

      focus_is_restrict_mk_rmem (pre `star` frame) pre (core_mem m0);

      let x = Sem.run #state #_ #_ #_ #_ #_ frame' (Sem.Frame (Sem.Act f) (hp_of frame) (req_frame frame snap)) in

      let m1 = nmst_get () in

      can_be_split_star_r pre frame;
      focus_is_restrict_mk_rmem (pre `star` frame) frame (core_mem m0);
      can_be_split_star_r (post x) frame;
      focus_is_restrict_mk_rmem (post x `star` frame) frame (core_mem m1);

      focus_is_restrict_mk_rmem (post x `star` frame) (post x) (core_mem m1);

      // We proved focus_rmem h0 frame == focus_rmem h1 frame so far
      let h0:rmem (pre `star` frame) = mk_rmem (pre `star` frame) (core_mem m0) in
      let h1:rmem (post x `star` frame) = mk_rmem (post x `star` frame) (core_mem m1) in

      lemma_frame_equalities_refl frame (focus_rmem h0 frame);

      x
#pop-options

let frame0 (#a:Type)
          (#pre:pre_t)
          (#post:post_t a)
          (#req:req_t pre)
          (#ens:ens_t pre a post)
          (f:repr a pre post req ens)
          (frame:vprop)
  : SteelSel a
    (pre `star` frame)
    (fun x -> post x `star` frame)
    (fun h -> (req (focus_rmem h pre)))
    (fun h0 r h1 -> (req (focus_rmem h0 pre) /\ ens (focus_rmem h0 pre) r (focus_rmem h1 (post r))
      /\ frame_equalities frame (focus_rmem h0 frame) (focus_rmem h1 frame)))
  = SteelSel?.reflect (frame00 f frame)

val frame' (#a:Type)
          (#pre:pre_t)
          (#post:post_t a)
          (#req:req_t pre)
          (#ens:ens_t pre a post)
          ($f:unit -> SteelSel a pre post req ens)
          (frame:vprop)
  : SteelSel a
    (pre `star` frame)
    (fun x -> post x `star` frame)
    (fun h -> (req (focus_rmem h pre)))
    (fun h0 r h1 -> (req (focus_rmem h0 pre) /\ ens (focus_rmem h0 pre) r (focus_rmem h1 (post r))
      /\ frame_equalities frame (focus_rmem h0 frame) (focus_rmem h1 frame)))

let frame' f frame = frame0 (reify (f ())) frame

let to_normal
  (#a:Type) (#pre:pre_t) (#post:post_t a) (#req:req_t pre) (#ens:ens_t pre a post)
  ($f:unit -> SteelSel a pre post (fun h -> req h) (fun h0 x h1 -> ens h0 x h1))
  : SteelSel a pre post
 (fun h -> normal (req h)) (fun h0 x h1 -> normal (ens h0 x h1))
  = f ()

let frame f fr = to_normal (fun _ -> frame' f fr)


let vemp' = {hp = emp; t = unit; sel = fun _ -> ()}
let vemp = VUnit vemp'

open FStar.Ghost


(* should do this in a more princpled way once we have automated framing *)
#push-options "--z3rlimit 50 --fuel 1 --ifuel 1"
let rewrite_20 (p q:vprop) : repr unit
  (p `star` q) (fun _ -> q `star` p)
  (requires fun _ -> True)
  (ensures fun h0 _ h1 -> h0 p == h1 p /\ h0 q == h1 q)
  = fun frame ->
      let m = nmst_get () in
      let h0 = mk_rmem (p `star` q) (core_mem m) in
      let h1 = mk_rmem (q `star` p) (core_mem m) in

     let vp = hide (h0 (p `star` q)) in
     let vq = hide (h1 (q `star` p)) in

     intro_star
          (p `star` q)
          (q `star` p)
          (frame `Mem.star` locks_invariant Set.empty m)
          vp vq
          m
          (fun _ -> ())
#pop-options

let rewrite_2 (p q:vprop) : SteelSel unit
  (p `star` q) (fun _ -> q `star` p)
  (requires fun h -> True)
  (ensures fun h0 _ h1 -> h0 p == h1 p /\ h0 q == h1 q)
  = SteelSel?.reflect (rewrite_20 p q)

(* Going towards automation. This already verifies *)

(*

unfold
let return_req (p:vprop) : req_t p = fun _ -> True

unfold
let return_ens (a:Type) (x:a) (p:a -> vprop) : ens_t (p x) a p = fun _ r _ -> r == x

(*
 * Return is parametric in post (cf. return-scoping.txt)
 *)
val return (a:Type) (x:a) (#[@@ framing_implicit] p:a -> vprop)
: repr a (p x) p (return_req (p x)) (return_ens a x p)

let return a x #p = fun _ -> x

unfold
let bind_req (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t)
  (req_g:(x:a -> req_t (pre_g x)))
  (_:squash (can_be_split_forall post_f pre_g))
: req_t pre_f
= fun m0 ->
  req_f m0 /\
  (forall (x:a) (m1:rmem (post_f x)). ens_f m0 x m1 ==> (req_g x) (focus_rmem m1 (pre_g x)))

unfold
let bind_ens (#a:Type) (#b:Type)
  (#pre_f:pre_t) (#post_f:post_t a)
  (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:a -> pre_t) (#post_g:post_t b)
  (ens_g:(x:a -> ens_t (pre_g x) b post_g))
  (_:squash (can_be_split_forall post_f pre_g))
: ens_t pre_f b post_g
= fun m0 y m2 ->
  req_f m0 /\
  (exists (x:a) (m1:rmem (post_f x)). ens_f m0 x m1 /\ (ens_g x) (focus_rmem m1 (pre_g x)) y m2)

val bind (a:Type) (b:Type)
  (#[@@ framing_implicit] pre_f:pre_t) (#[@@ framing_implicit] post_f:post_t a)
  (#[@@ framing_implicit] req_f:req_t pre_f) (#[@@ framing_implicit] ens_f:ens_t pre_f a post_f)
  (#[@@ framing_implicit] pre_g:a -> pre_t) (#[@@ framing_implicit] post_g:post_t b)
  (#[@@ framing_implicit] req_g:(x:a -> req_t (pre_g x))) (#[@@ framing_implicit] ens_g:(x:a -> ens_t (pre_g x) b post_g))
  (#[@@ framing_implicit] p1:squash (can_be_split_forall post_f pre_g))
  (f:repr a pre_f post_f req_f ens_f)
  (g:(x:a -> repr b (pre_g x) post_g (req_g x) (ens_g x)))
: repr b
    pre_f
    post_g
    (bind_req req_f ens_f req_g p1)
    (bind_ens req_f ens_f ens_g p1)

let nmst_get (#st:Sem.st) ()
  : Sem.Mst (Sem.full_mem st)
           (fun _ -> True)
           (fun s0 s s1 -> s0 == s /\ s == s1)
  = NMST.get ()

let bind a b #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #p1 f g = fun frame ->

  let x = f frame in

  let m1 = nmst_get () in

  focus_is_restrict_mk_rmem (post_f x) (pre_g x) (core_mem m1);
  assert ((req_g x) (mk_rmem (pre_g x) (core_mem m1)));

  can_be_split_3_interp (post_f x).hp (pre_g x).hp frame (locks_invariant Set.empty m1) m1;

  g x frame


unfold
let subcomp_pre (#a:Type)
  (#pre_f:pre_t) (#post_f:post_t a) (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
  (#pre_g:pre_t) (#post_g:post_t a) (req_g:req_t pre_g) (ens_g:ens_t pre_g a post_g)
  (_:squash (can_be_split pre_g pre_f))
  (_:squash (can_be_split_forall post_f post_g))
: pure_pre
= (forall (m0:rmem pre_g). req_g m0 ==> req_f (focus_rmem m0 pre_f)) /\
  (forall (m0:rmem pre_g) (x:a) (m1:rmem (post_f x)). ens_f (focus_rmem m0 pre_f) x m1 ==> ens_g m0 x (focus_rmem m1 (post_g x)))

val subcomp (a:Type)
  (#[@@ framing_implicit] pre_f:pre_t) (#[@@ framing_implicit] post_f:post_t a)
  (#[@@ framing_implicit] req_f:req_t pre_f) (#[@@ framing_implicit] ens_f:ens_t pre_f a post_f)
  (#[@@ framing_implicit] pre_g:pre_t) (#[@@ framing_implicit] post_g:post_t a)
  (#[@@ framing_implicit] req_g:req_t pre_g) (#[@@ framing_implicit] ens_g:ens_t pre_g a post_g)
  (#[@@ framing_implicit] p1:squash (can_be_split pre_g pre_f))
  (#[@@ framing_implicit] p2:squash (can_be_split_forall post_f post_g))
  (f:repr a pre_f post_f req_f ens_f)
: Pure (repr a pre_g post_g req_g ens_g)
  (requires subcomp_pre req_f ens_f req_g ens_g p1 p2)
  (ensures fun _ -> True)

let subcomp a #pre_f #post_f #req_f #ens_f #pre_g #post_g #req_g #ens_g #p1 #p2 f =
  fun frame ->

    let m0 = nmst_get () in
    focus_is_restrict_mk_rmem pre_g pre_f (core_mem m0);

    let x = f frame in

    let m1 = nmst_get () in
    focus_is_restrict_mk_rmem (post_f x) (post_g x) (core_mem m1);

    can_be_split_3_interp (post_f x).hp (post_g x).hp frame (locks_invariant Set.empty m1) m1;

    x


[@@allow_informative_binders]
reifiable reflectable
layered_effect {
  SteelSel: a:Type -> pre:pre_t -> post:post_t a -> req_t pre -> ens_t pre a post -> Effect
  with repr = repr;
       return = return;
       bind = bind;
       subcomp = subcomp
}

unfold
let bind_pure_steel__req (#a:Type) (wp:pure_wp a)
  (#pre:pre_t) (req:a -> req_t pre)
: req_t pre
= fun m -> wp (fun x -> (req x) m) /\ as_requires wp

unfold
let bind_pure_steel__ens (#a:Type) (#b:Type)
  (wp:pure_wp a)
  (#pre:pre_t) (#post:post_t b) (ens:a -> ens_t pre b post)
: ens_t pre b post
= fun m0 r m1 -> as_requires wp /\ (exists (x:a). as_ensures wp x /\ (ens x) m0 r m1)

assume
val bind_pure_steel_ (a:Type) (b:Type)
  (wp:pure_wp a)
  (#[@@ framing_implicit] pre:pre_t) (#[@@ framing_implicit] post:post_t b)
  (#[@@ framing_implicit] req:a -> req_t pre) (#[@@ framing_implicit] ens:a -> ens_t pre b post)
  (f:eqtype_as_type unit -> PURE a wp) (g:(x:a -> repr b pre post (req x) (ens x)))
: repr b
    pre
    post
    (bind_pure_steel__req wp req)
    (bind_pure_steel__ens wp ens)

polymonadic_bind (PURE, SteelSel) |> SteelSel = bind_pure_steel_

unfold
let bind_div_steel_req (#a:Type) (wp:pure_wp a)
  (#pre_g:pre_t) (req_g:a -> req_t pre_g)
: req_t pre_g
= FStar.Monotonic.Pure.wp_monotonic_pure ();
  fun h -> wp (fun _ -> True) /\ (forall x. (req_g x) h)

unfold
let bind_div_steel_ens (#a:Type) (#b:Type)
  (wp:pure_wp a)
  (#pre_g:pre_t) (#post_g:post_t b) (ens_g:a -> ens_t pre_g b post_g)
: ens_t pre_g b post_g
= fun h0 r h1 -> wp (fun _ -> True) /\ (exists x. ens_g x h0 r h1)


assume
val bind_div_steel (a:Type) (b:Type)
  (wp:pure_wp a)
  (pre_g:pre_t) (post_g:post_t b) (req_g:a -> req_t pre_g) (ens_g:a -> ens_t pre_g b post_g)
  (f:eqtype_as_type unit -> DIV a wp) (g:(x:a -> repr b pre_g post_g (req_g x) (ens_g x)))
: repr b pre_g post_g
    (bind_div_steel_req wp req_g)
    (bind_div_steel_ens wp ens_g)

polymonadic_bind (DIV, SteelSel) |> SteelSel = bind_div_steel

*)



// unfold
// let bind_steel_steelf_req (#a:Type)
//   (#pre_f:pre_t) (#post_f:post_t a)
//   (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
//   (#pre_g:a -> pre_t)
//   (req_g:(x:a -> req_t (pre_g x)))
//   (frame_f:vprop)
//   (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
// : req_t (pre_f `star` frame_f)
// = fun m0 ->
//   req_f (focus_rmem m0 pre_f) /\
//   (forall (x:a) (m1:rmem (post_f x `star` frame_f)). ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) ==> (req_g x) (focus_rmem m1 (pre_g x)))

// unfold
// let bind_steel_steelf_ens (#a:Type) (#b:Type)
//   (#pre_f:pre_t) (#post_f:post_t a)
//   (req_f:req_t pre_f) (ens_f:ens_t pre_f a post_f)
//   (#pre_g:a -> pre_t) (#post_g:post_t b)
//   (ens_g:(x:a -> ens_t (pre_g x) b post_g))
//   (frame_f:vprop)
//   (_:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
// : ens_t (pre_f `star` frame_f) b post_g
// = fun m0 y m2 ->
//   req_f (focus_rmem m0 pre_f) /\
//   (exists (x:a) (m1:rmem (post_f x `star` frame_f)).
//     ens_f (focus_rmem m0 pre_f) x (focus_rmem m1 (post_f x)) /\ (ens_g x) (focus_rmem m1 (pre_g x)) y m2)

// val bind_steel_steelf (a:Type) (b:Type)
//   (#pre_f:pre_t) (#post_f:post_t a)
//   (#req_f:req_t pre_f) (#ens_f:ens_t pre_f a post_f)
//   (#pre_g:a -> pre_t) (#post_g:post_t b)
//   (#req_g:(x:a -> req_t (pre_g x))) (#ens_g:(x:a -> ens_t (pre_g x) b post_g))
//   (#frame_f:vprop)
//   (#p:squash (can_be_split_forall (fun x -> post_f x `star` frame_f) pre_g))
//   (f:repr a pre_f post_f req_f ens_f)
//   (g:(x:a -> repr b (pre_g x) post_g (req_g x) (ens_g x)))
// : repr b
//     (pre_f `star` frame_f)
//     post_g
//     (bind_steel_steelf_req req_f ens_f req_g frame_f p)
//     (bind_steel_steelf_ens req_f ens_f ens_g frame_f p)

// // let frame_aux (#a:Type)
// //   (#pre:pre_t) (#post:post_t a) (#req:req_t pre) (#ens:ens_t pre a post)
// //   ($f:repr a pre post req ens) (frame:vprop)
// // : repr a (pre `star` frame) (fun x -> post x `star` frame) req ens
// // = fun frame' ->
// //   Sem.run #state #_ #_ #_ #_ #_ frame' (Sem.Frame (Sem.Act f) frame (fun _ -> True))


// let bind_steel_steelf a b f g =
//   fun frame' -> admit()
*)
