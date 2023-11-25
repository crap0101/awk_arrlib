
@include "arrlib"
@include "awkpot"
# https://github.com/crap0101/awkpot
@include "testing"
# https://github.com/crap0101/awk_testing

@load "arrayfuncs"
# https://github.com/crap0101/awk_arrayfuncs
@load "sysutils"
# https://github.com/crap0101/awk_sysutils


function _rec(arr,    i) {
    # ricorsione infinita...
    # stoppato a 529128, nessun stack overflow ma si blocca il pc :-D
    #print i
    for (idx in arr) {
	print idx
	delete arr[idx]
	arr[idx][i] = i
	rec(arr[idx], i+1)
    }
}


BEGIN {
    if (awk::ARRLIB_DEBUG) {
	dprint = "awkpot::dprint_real"
	# to set dprint in awkpot functions also (defaults to dprint_fake)
	awkpot::set_dprint(dprint)
    } else {
	dprint = "awkpot::dprint_fake"
    }

    _stdout = "" # set false for printa to print on stdout
    # "arr" array with subarrays:
    for (i=0;i<5;i++)
	if (i % 2 == 0) {
	    for (j=0;j<5;j++)
		if (j % 2 == 0)
		    arr[i][j] = i","j
		else
		    arr[i][j] = (i+1)*(j+1)
	} else
	    arr[i] = i
    # array a
    a["foo"] = "vfoo"
    a["bar"][1] = "bar1"
    a["bar"][2] = "bar2"
    a["bar"][3] = "bar3"
    a["bar"][4][1] = 1
    a["bar"][4][2] = 2
    a["spam"][1] = "spam1"
    a["spam"][2] = "spam2"
    a["spam"][3] = "spam3"
    # array ba
    ba[0]=0
    ba[1]=1
    ba[5]=""
    ba["foo"][1]="foo1"
    ba["foo"][2]="foo2"
    ba["foo"][3]=""
    ba["spam"][1][0]="s1-0"
    ba["spam"][1][2]="s1-2"
    ba["spam"][1][3]="s1-3"
    ba[2][3][4][0] = "4th_0"
    ba[2][3][4][1] = "4th_1"
    # array bg
    bg["A"]=0
    bg[0]=1
    bg[1]=""
    bg[2]=9
    bg["B"][1]="B1"
    bg["B"][2]="B2"
    bg["C"]["C1"][0]="C1-0"
    bg["C"]["C1"][2]="C1-2"
    bg["C"]["C1"][3]="C1-3"
    bg["D"]["E"]["F"][0] = "DEF_0"
    bg["D"]["E"]["F"][1] = "DEF_1"

    testing::start_test_report()
	
    # TEST arrlib::copy && sorting order
    @dprint("* array_copy(arr, b)")
    arrlib::copy(arr, b)
    @dprint("* arr:") && arrlib::printa(arr)
    @dprint("* b:") && arrlib::printa(b)
    testing::assert_true(arrlib::equals(arr, b), 1, "> arrlib::equals(arr, b)")
    @dprint("* arrlib::copy(b, x)")
    arrlib::copy(b, x)
    @dprint("* x:") && arrlib::printa(x)
    testing::assert_true(arrlib::equals(x, b), 1, "> arrlib::equals(x, b)")
    @dprint("* _prev_order = awkpot::set_sort_order(\"@ind_num_desc\")")
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* printa(b)") && arrlib::printa(b)
    @dprint("* arrlib::copy(b, b1)")
    arrlib::copy(b, b1)
    @dprint("* b1:") && arrlib::printa(b1)
    @dprint("* awkpot::set_sort_order(_prev_order)")
    awkpot::set_sort_order(_prev_order)
    testing::assert_true(arrlib::equals(b1, b), 1, "> arrlib::equals(b1, b)")
    @dprint("* b1:") && arrlib::printa(b1)
    @dprint(sprintf("* b1 (sprintfa): <%s>", arrlib::sprintfa(b1)))

    @dprint("* array_copy(bg, c, 3, 1)")
    arrlib::copy(bg, c, 3, 1)
    bgstr = arrlib::sprintfa(bg, 3, 1)
    @dprint(sprintf("* sprintfa(bg, 3, 1): <%s>", bgstr))
    cs = arrlib::sprintfa(c)
    testing::assert_equal(cs, bgstr, 1, "> cs == bgstr")

    arrlib::copy(bg, d, 1)
    bgstr1 = arrlib::sprintfa(bg, 1)
    ds = arrlib::sprintfa(d)
    testing::assert_equal(ds, bgstr1, 1, "> ds == bgs1")
    
    arrlib::copy(bg, c)
    testing::assert_true(arrlib::equals(bg, c), 1, "> arrlib::equals(bg, c)")

    delete b1; delete c; delete d; delete x;
				   
    # TEST printing
    # sprintfa, sort order, ...
    x["x"]="xx";x[0]=1;x[1]="zero";x[2]=3
    @dprint("* x:") && arrlib::printa(x)
    @dprint("* printa(x, _stdout, -1, -1, \"@ind_num_desc\"):") && arrlib::printa(x, _stdout, -1, -1, "@ind_num_desc")
    arrlib::copy(b, b1)
    b1s = arrlib::sprintfa(b1)
    testing::assert_equal(arrlib::sprintfa(b), b1s, 1,
			  "> arrlib::sprintfa(b) == arrlib::sprintfa(b1)")

    @dprint("* _prev_order = set_sort_order(\"@ind_num_desc\")")
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* arrlib::printa(ba):") && arrlib::printa(ba)
    @dprint("* arrlib::copy(ba, bc)")
    arrlib::copy(ba, bc)
    @dprint("* arrlib::printa(bc)") && arrlib::printa(bc)
    bsa = arrlib::sprintfa(ba)
    @dprint(sprintf("* bsa = arrlib::sprintfa(ba): <%s>", bsa))
    bsc = arrlib::sprintfa(bc)
    testing::assert_equal(bsa, bsc, 1, "> bsa == bsc")
    delete b1; delete bc
    
    # sprintf_vals
    _t3 = sys::mktemp("/tmp")
    arrlib::print_idxs(ba, _t3)
    awkpot::read_file_arr(_t3, bf)
    array::deep_flat_idx(ba, bbg)
    asort(bbg)
    bs = arrlib::sprintf_vals(bbg, ":")
    bs_over = arrlib::sprintf_vals(bbg, ":", 1 + arrlib::deep_length(bbg))
    bs_neg = arrlib::sprintf_vals(bbg, ":", 0)
    asort(bf)
    bfs = arrlib::sprintf_vals(bf, ":")
    testing::assert_equal(bs, bfs, 1, "> bs == bfs")
    testing::assert_equal(bs_over, bfs, 1, "> bs_over == bfs")
    testing::assert_equal(bs, bs_neg, 1, "> bs == bs_neg")
    sys::rm(_t3)
    
    # check empty values
    _pv = awkpot::set_sort_order("@val_str_asc")
    va[0] = ""
    va[1] = 1
    va[2] = ""
    va[3] = 2
    va[4] = ""
    testing::assert_equal(arrlib::sprintf_vals(va, ":"), ":::1:2", 1, "> sprintf_vals (empty values) [@val_str_asc]")
    awkpot::set_sort_order("@ind_num_asc")
    testing::assert_equal(arrlib::sprintf_vals(va, ":"), ":1::2:", 1, "> sprintf_vals (empty values) [@ind_num_asc]")
    @dprint(sprintf("* vals <%s>\n", arrlib::sprintf_vals(va, ":")))
    va[0]=0
    va[4]=4
    @dprint("* set va[0]=0; va[4]=4")
    testing::assert_equal(arrlib::sprintf_vals(va, ":"), "0:1::2:4", 1, "> sprintf_vals")
    @dprint("* set va[2]=\"due\"")
    va[2]="due"
    testing::assert_equal(arrlib::sprintf_vals(va, ":"), "0:1:due:2:4", 1, "> sprintf_vals")
    va[5][0]=""
    va[5][1]=11
    va[5][2]=""
    va[5][3]
    va[6][0]=""
    va[6][1]=""
    testing::assert_equal(arrlib::sprintf_vals(va, ":"), "0:1:due:2:4::11::::", 1, "> sprintf_vals (subarrays)")
    delete va

    # sprintf_idxs
    va[0] = ""
    va[1] = 1
    va[2] = ""
    va[3] = 2
    va[4] = ""

    testing::assert_equal(arrlib::sprintf_idxs(va, ":"), "0:1:2:3:4", 1, "> sprintf_idxs")
    testing::assert_equal(arrlib::array_length(va), 5, 1, "(length) va == 5")
    va[""]="null"
    testing::assert_true(("" in va), 1, "> null in va?")
    testing::assert_equal(arrlib::sprintf_idxs(va, ":"), ":0:1:2:3:4", 1, "> sprintf_idxs (empty index)")
    testing::assert_equal(arrlib::array_length(va), 6, 1, "(length) va == 6")
    va[5][0]=""
    va[5][1]=11
    va[5][2]=""
    va[5][3]
    va[6][0]=""
    va[6][1]=""
    testing::assert_equal(arrlib::sprintf_idxs(va, ":"), ":0:1:2:3:4:5:0:1:2:3:6:0:1", 1, "> sprintf_idxs (subarrays)")
    delete va[""]

    awkpot::set_sort_order(_pv)
    delete va
    
    bs1 = arrlib::sprintf_idxs(bbg, ":")
    bs2 = ""
    for (i=arrlib::array_length(bbg); i>1; i--)
	bs2 = bs2 i ":"
    bs2 = bs2 "" i
    testing::assert_equal(bs1, bs2, 1, "> bs == bs2")
    delete bd;delete be;delete bf;delete bbg

    # with depth
    _t1 = sys::mktemp("/tmp")
    _t2 = sys::mktemp("/tmp")
    @dprint(sprintf("* arrlib::printa(ba, %s)", _t1))
    arrlib::printa(ba, _t1, 2)
    bs = arrlib::sprintfa(ba, 2)
    printf("%s",bs) >> _t2
    close(_t2)
    awkpot::read_file_arr(_t1, ba_read)
    awkpot::read_file_arr(_t2, bs_read)
    @dprint("* ba_read:") && arrlib::printa(ba_read)
    @dprint("* bs_read:") && arrlib::printa(bs_read)
    testing::assert_true(arrlib::equals(ba_read, bs_read), 1, "> ba_read == bs_read")
    sys::rm(_t1)
    sys::rm(_t2)
    
    # sprintf_vals
    _t3 = sys::mktemp("/tmp")
    arrlib::print_vals(ba, _t3, 2)
    awkpot::read_file_arr(_t3, ba_read)
    @dprint("* ba_read:") && arrlib::printa(ba_read)
    asort(ba_read)
    ba_str = arrlib::sprintf_vals(ba_read, ":")
    arrlib::copy(ba, ba_pcopy, 2)
    @dprint("* ba_pcopy:") && arrlib::printa(ba_pcopy)
    sys::rm(_t3)
    
    #arrlib::printa
    array::deep_flat(ba_pcopy, ba_flat)
    @dprint("* ba_flat:") && arrlib::printa(ba_flat)
    asort(ba_flat)
    ba_flat_str = arrlib::sprintf_vals(ba_flat, ":")
    @dprint(sprintf("* ba_str: <%s>", ba_str))
    @dprint(sprintf("* ba_flat_str: <%s>", ba_flat_str))
    testing::assert_equal(ba_str, ba_flat_str, 1, "> ba_str == ba_flat_str")

    # sprintf_idxs, sprintf_vals (slices)
    @dprint("* bg:") && arrlib::printa(bg)
    bgstr = arrlib::sprintf_idxs(bg, ":", 2)
    @dprint(sprintf("* bgstr: <%s>", bgstr))
    split(bgstr, bgs, ":")
    asort(bgs)
    test_bgs = "A:0:1:2:B:C:D:1:2:C1:E"
    split(test_bgs, bgt, ":")
    asort(bgt)
    testing::assert_true(arrlib::equals(bgs, bgt), 1, "> sprintf_idxs (depth=2): bgs == bgt")

    bgvstr = arrlib::sprintf_vals(bg, ":", 2)
    split(bgvstr, bgvs, ":")
    asort(bgvs)
    test_bgv = "0:1::9:B1:B2"
    split(test_bgv, bgv, ":")
    asort(bgv)
    testing::assert_true(arrlib::equals(bgvs, bgv), 1, "> sprintf_vals (depth=2): bgvs == bgv")

    delete bd;delete be;delete bf
    delete bgs; delete bgt; delete bgvs; delete bgv
    delete ba_read;delete ba_pcopy;delete ba_flat; delete ba_flat2

    bastr = arrlib::sprintf_idxs(bg, ":", 3, 1)
    @dprint(sprintf("* bastr: <%s>", bastr))
    split(bastr, bas, ":")
    asort(bas)
    test_bas = "1:2:C1:E:0:2:3:F"
    split(test_bas, bat, ":")
    asort(bat)
    testing::assert_true(arrlib::equals(bas, bat), 1, "> sprintf_idxs (depth=3, from=1): bas == bat")

    bavstr = arrlib::sprintf_vals(bg, ":", 3, 1)
    split(bavstr, bavs, ":")
    asort(bavs)
    test_bav = "B1:B2:C1-0:C1-2:C1-3"
    split(test_bav, bav, ":")
    asort(bav)
    testing::assert_true(arrlib::equals(bavs, bav), 1, "> sprintf_vals (depth=3, from =1): bavs == bav")
    delete bas; delete bat; delete bavs; delete bav

    _t1 = sys::mktemp("/tmp")
    arrlib::print_idxs(a, _t1)
    awkpot::read_file_arr(_t1, _c)
    awk::asort(_c)
    array::deep_flat_idx(a, _a)
    awk::asort(_a)
    @dprint(sprintf("* indexes from _a: <%s>", arrlib::sprintf_vals(_a, ":")))
    @dprint(sprintf("* indexes from _c: <%s>", arrlib::sprintf_vals(_c, ":")))
    testing::assert_equal(arrlib::sprintf_vals(_a, ":"), arrlib::sprintf_vals(_c, ":"),
			  1, "> (idx from _a) == (idx from _c)")
    sys::rm(_t1)
    
    _t1 = sys::mktemp("/tmp")
    arrlib::print_vals(a, _t1)
    awkpot::read_file_arr(_t1, _d)
    awk::asort(_d)
    array::deep_flat(a, _b)    
    awk::asort(_b)
    @dprint(sprintf("* indexes from _b: <%s>", arrlib::sprintf_vals(_b, ":")))
    @dprint(sprintf("* indexes from _d: <%s>", arrlib::sprintf_vals(_d, ":")))
    testing::assert_equal(arrlib::sprintf_vals(_b, ":"), arrlib::sprintf_vals(_d, ":"), 1,
			  "> (val from _b) == (val from _d)")
    @dprint("* set_sort_order(_prev_order)")
    awkpot::set_sort_order(_prev_order)
    sys::rm(_t1)
	
    # TEST arrlib::exists*
    arr["foo"]["bar"] = 12.2
    arr["foo"]["baz"] = "foo"
    @dprint("* arr:") && arrlib::printa(arr)
    testing::assert_false(arrlib::exists(arr, "eggs"), 1, "> ! arrlib::exists(arr, \"eggs\")")
    testing::assert_false(arrlib::exists(arr, 4), 1, "> ! arrlib::exists(arr, 4)")
    testing::assert_false(arrlib::exists(arr, 10), 1, "> ! arrlib::exists(arr, 10)")
    testing::assert_true(arrlib::exists_deep(arr, 10), 1, "> arrlib::exists_deep(arr, 10)")
    testing::assert_false(arrlib::exists_deep(arr, 2, 1), 1, "> ! arrlib::exists_deep(arr, 2, 1)")
    testing::assert_true(arrlib::exists_deep(arr, 2, 2), 1, "> arrlib::exists_deep(arr, 2, 2)")
    testing::assert_false(arrlib::exists(arr, 12.2), 1, "> ! arrlib::exists(arr, 12.2)")
    testing::assert_true(arrlib::exists_deep(arr, 12.2), 1, "> arrlib::exists_deep(arr, 12.2)")
    testing::assert_false(arrlib::exists(arr, "foo"), 1, "> ! arrlib::exists(arr, \"foo\")")
    testing::assert_true(arrlib::exists_deep(arr, "foo"), 1, "> arrlib::exists_deep(arr, \"foo\")")
    testing::assert_true(arrlib::exists_deep(arr, "4,2"), 1, "> arrlib::exists_deep(arr, \"4,2\"): ")
    testing::assert_true(arrlib::exists_index(arr, 3), 1, "> arrlib::exists_index(arr, 3)")
    testing::assert_true(arrlib::exists_index_deep(arr, 3), 1, "> arrlib::exists_index_deep(arr, 3)")
    testing::assert_false(arrlib::exists_index(arr, "bar"), 1, "> ! arrlib::exists_index(arr, \"bar\")")
    testing::assert_true(arrlib::exists_index_deep(arr, "bar"), 1, "> arrlib::exists_index_deep(arr, \"bar\")")
    @dprint("* delete arr ...")
    delete arr
    testing::assert_false(arrlib::exists_index_deep(arr, "bar"), 1, "> arrlib::exists_index_deep(arr, \"bar\")")
    @dprint("* set $1 = \"m\"; $2 = \"ll\"; $3 = \"?\"; $4 = 5; $5 = 99")

    # TEST arrlib::make_records && arrlib::exists_record
    $1 = "m"; $2 = "ll"; $3 = "?"; $4 = 5; $5 = 99
    testing::assert_false(arrlib::exists_record("?", 2), 1, "> ! exists_record(\"?\", 2)")
    testing::assert_true(arrlib::exists_record("?", 3), 1, "> exists_record(\"?\", 3)")
    testing::assert_true(arrlib::exists_record("?", 11), 1, "> exists_record(\"?\", 11)")
    testing::assert_false(arrlib::exists_record("not_existent", 11), 1, "> ! exists_record(\"not_existent\", 11)")
    testing::assert_true(arrlib::exists_record(5, 4), 1, "> exists_record(5, 4)")
    @dprint("* make_array_record(b)")
    arrlib::make_array_record(b)
    @dprint("* b:") && arrlib::printa(b)
    testing::assert_equal(arrlib::array_length(b), 5, 1, "> array_length(b) == 5")
    @dprint("* array_copy(b, c)")
    arrlib::copy(b, c)
    @dprint("* c:") && arrlib::printa(c)
    @dprint("* b:") && arrlib::printa(b)
    testing::assert_true(arrlib::equals(b, c), 1, "> arrlib::equals(b, c)")
    for (i in b)
	testing::assert_equal(b[i], c[i], 1,
			      sprintf("> b[%s] == c[%s] --> (%s, %s)", i, i, b[i], c[i]))

    # TEST arrlib::*length
    @dprint("* delete b")
    delete b
    @dprint("* b:") && arrlib::printa(b)
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> test array_length(b) == 0")

    @dprint("* delete a")
    delete a
    a[1]
    a[2]
    a[3][1]
    a[3][2]
    a[4]
    @dprint("* a:") && arrlib::printa(a)
    testing::assert_equal(arrlib::array_length(a), arrlib::deep_length(a, 1), 1, "> test array_length/deep_length(a)")
    @dprint("* delete a[3]")
    delete a[3]
    testing::assert_equal(arrlib::array_length(a), arrlib::deep_length(a, 1), 1, "> test array_length/deep_length(a, 1)")
    testing::assert_equal(arrlib::array_length(a), arrlib::deep_length(a), 1, "> test array_length/deep_length(a)")
    
    @dprint("* delete a")
    delete a
    a["foo"] = "vfoo"
    a["bar"][1] = "bar1"
    a["bar"][2] = "bar2"
    a["bar"][3] = "bar3"
    a["bar"][4][1] = 1
    a["bar"][4][2] = 2
    a["spam"][1] = "spam1"
    a["spam"][2] = "spam2"
    a["spam"][3] = "spam3"
    @dprint("* a:") && arrlib::printa(a)
    testing::assert_equal(arrlib::array_length(a), 3, 1, "> array_length(a) == 3 -->")
    testing::assert_equal(arrlib::deep_length(a), 9, "> array_deep_length(a) == 9")
    @dprint("* delete b")
    delete b
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> array_length(b) == 0")
    testing::assert_equal(arrlib::deep_length(b), 0, 1, "> array_deep_length(b) == 0")
    @dprint("* delete x")
    delete x
    @dprint("* set x[0]=0;x[1]=1;x[2]=2")
    x[0]=0;x[1]=1;x[2]=2
    testing::assert_equal(arrlib::array_length(x), 3, 1, "> array_length(x) == 3")
    testing::assert_equal(arrlib::deep_length(x), 3, 1, "> array_deep_length(x) == 3")
    @dprint("* delete x")
    delete x

    # TEST arrlib::equals
    @dprint("* delete c")
    delete c
    @dprint("* arrlib::copy(a, b)")
    arrlib::copy(a, b)
    @dprint("* array::copy(a, c)")
    array::copy(a, c)
    testing::assert_true(arrlib::equals(b, c), 1, "> arrlib::equals(b, c)")
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    @dprint("* set a[1] = 1")
    a[1] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    testing::assert_false(arrlib::equals(a, c), 1, "> ! arrlib::equals(a, c)")
    @dprint("* delete a[1]")
    delete a[1]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    testing::assert_true(arrlib::equals(a, c), 1, "> arrlib::equals(a, c)")

    @dprint("* set a[\"spam\"][1] = 4; b[\"spam\"][5] = 5")
    a["spam"][1] = 4
    b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    @dprint("* set a[\"spam\"][1] = \"spam1\"")
    a["spam"][1] = "spam1"
    @dprint("* delete  b[\"spam\"][5]")
    delete b["spam"][5]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")

    @dprint("* set a[\"spam\"][4] = 4")
    a["spam"][4] = 4
    @dprint("* set b[\"spam\"][5] = 5")
    b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")

    @dprint("* delete a[\"spam\"][4]")
    delete a["spam"][4]
    @dprint("* delete b[\"bar\"][5]")
    delete  b["spam"][5]
    testing::assert_true(arrlib::sprintfa(b) == arrlib::sprintfa(b), 1, "> (sprintf) a == b)")
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    
    @dprint("* set b[1] = 1")
    b[1] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    @dprint("* delete b[1]")
    delete b[1]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    @dprint("* set b[\"spam\"][3] = \"spam2\"")
    b["spam"][3] = "spam2"
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    @dprint("* set a[\"spam\"][3] = \"spam2\"")
    a["spam"][3] = "spam2"
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    @dprint("* set b[\"spam\"][5] = 5")
    b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b) =")
    @dprint("* delete b[\"spam\"][5] = 5")
    delete b["spam"][5]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    @dprint("* set a[\"bar\"][4][3] = 3")
    a["bar"][4][3] = 3
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    @dprint("* delete a[\"bar\"][4][3]")
    delete a["bar"][4][3]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    @dprint("* set b[\"bar\"][4][11] = 11")
    b["bar"][4][11] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    @dprint("* delete b[\"bar\"][4][11]")
    delete b["bar"][4][11]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")

    delete arr1;delete arr2
    arr1["foo"] = 1
    arr2["foo"][1] = 1
    testing::assert_false(arrlib::equals(arr1,arr2), 1, "> ! equals(arr1, arr2)")
    delete arr2["foo"]
    arr2["foo"] = 1
    testing::assert_true(arrlib::equals(arr1,arr2), 1, "> equals(arr1, arr2)")
    delete arr1;delete arr2

    # TEST empty
    testing::assert_false(arrlib::is_empty(b), 1, "> ! arrlib::is_empty(b)")
    testing::assert_true(arrlib::array_length(b) > 0, 1, "> arrlib::array_length(b) > 0")
    @dprint("* delete b")
    delete b
    testing::assert_true(arrlib::is_empty(b), 1, "> arrlib::is_empty(b)")
    testing::assert_false(arrlib::array_length(b), 1, "> arrlib::array_length(b) == 0")
    @dprint("* set b[0]=0;b[1]=1")
    b[0]=0;b[1]=1
    testing::assert_false(arrlib::is_empty(b), 1, "> ! arrlib::is_empty(b)")
    @dprint("* delete b[0]")
    delete b[0]
    testing::assert_false(arrlib::is_empty(b), 1, "> ! arrlib::is_empty(b)")
    @dprint("delete b[1]")
    delete b[1]
    testing::assert_true(arrlib::is_empty(b), 1, "> arrlib::is_empty(b)")
    delete b
    
    # TEST test remove_empty && # TEST arrlib::copy with unassigned values
    arrlib::copy(ba, bb)
    testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    @dprint("* ba:") && arrlib::printa(ba)
    @dprint("* bb:") && arrlib::printa(bb)
    @dprint("* adding fake arrays to bb")
    bb["X-X-X"]
    bb["eggs"][0]
    bb["eggs"][1]
    bb["eggs"][2][1][2]
    bb["eggs"][2][1][2]
    @dprint("bb:") && arrlib::printa(bb)

    ba_len = arrlib::deep_length(ba)
    bb_len = arrlib::deep_length(bb)
    testing::assert_not_equal(ba_len, bb_len, 1, "> (len) ba != (len) bb)")
    @dprint(sprintf("* (length) ba: %d, bb: %d", ba_len, bb_len))
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    
    @dprint("* arrlib::copy(bb, bc)")
    arrlib::copy(bb, bc)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    bb_str = arrlib::sprintfa(bb)
    bc_str = arrlib::sprintfa(bc)
    @dprint(sprintf("* bb_str: <%s>", bb_str))
    @dprint(sprintf("* bc_str: <%s>", bc_str))
    testing::assert_equal(bb_str, bc_str, 1, "> (sprintf) bb == bc")
    awkpot::set_sort_order(_prev_order)

    #print "* bc:";arrlib::printa(bc)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")

    @dprint("* remove_empty(bb)")
    arrlib::remove_empty(bb) # fake arrays not empty, so not removed
    @dprint("* bb:") && arrlib::printa(bb)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    testing::assert_not_equal(ba_len, arrlib::deep_length(bb), 1, "> (len) ba != (len) bb)")
    @dprint(sprintf("* (length) ba: %d, bb: %d", arrlib::deep_length(ba), arrlib::deep_length(bb)))

    @dprint("* remove unassigned elements from bb")
    arrlib::remove_unassigned(bb) # now fake arrays are removed, unassigned elements too

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* ba:") && arrlib::printa(ba)
    @dprint("* bb:") && arrlib::printa(bb)
    @dprint("* bc:") && arrlib::printa(bb)
    # XXX+NOTE_1: at this time (2023-11-18), on gawk 5.3.0 (but also, at least, down to 5.2.2)
    # unassigned values becomes string! So, skip this test...
    # see https://lists.gnu.org/archive/html/bug-gawk/2023-11/msg00012.html
    # ...TODO: working on this to be more transparent...
    if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	testing::assert_false(arrlib::equals(bb, bc), 1, "> ! arrlib::equals(bc, bb)")

    @dprint("* arrlib::remove_unassigned(bc)")
    arrlib::remove_unassigned(bc) # remove fakes from bc too
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bc, bb)")

    # See above NOTE_1 ...
    if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	testing::assert_equal(ba_len, arrlib::deep_length(bb), 1, "> (len) ba == (len) bb")
    @dprint(sprintf("* (length) ba: %d, bb: %d", arrlib::deep_length(ba), arrlib::deep_length(bb)))
    # See above NOTE_1 ...
    if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	testing::assert_equal(arrlib::sprintfa(bb), arrlib::sprintfa(ba), 1, "> (sprintf) bb == ba")
    awkpot::set_sort_order(_prev_order)

    # See above NOTE_1 ...
    if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le")) {
	testing::assert_false(("eggs" in bb), 1, "> ! (\"eggs\" in bb)")
	testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    }

    delete bd
    @dprint("* arrlib::copy(bb, bd)")
    arrlib::copy(bb, bd)
    @dprint("* bd:") && arrlib::printa(bd)
    testing::assert_equal(arrlib::deep_length(bd), arrlib::deep_length(bb), 1, "> (len) bd == (len) bb)")
    testing::assert_true(arrlib::equals(bb, bd), 1, "> arrlib::equals(bd, bb)")
    
    # TEST get_idxs / get_vals
    delete idxarr
    @dprint("* test get_idxs:")
    @dprint("* bg:") && arrlib::printa(bg)
    count = arrlib::get_idxs(bg, idxarr)

    @dprint("* idxarr:") && arrlib::printa(idxarr)
    idxstr = arrlib::sprintf_vals(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")

    count = arrlib::get_vals(idxarr, valarr)
    @dprint("* valarr:") && arrlib::printa(valarr)
    valstr = arrlib::sprintf_vals(valarr, ":")
    @dprint(sprintf("* valstr: <%s>", valstr))
    testing::assert_equal(count, arrlib::array_length(valarr), 1, "> (valarr) count == length")

    testing::assert_equal(valstr, idxstr, 1, "> valstr == idxstr")

    # test on flat arrays
    delete chrarr
    delete valarr
    delete idxarr
    _prev_order = awkpot::set_sort_order("@ind_num_asc")

    for (i=50; i<100; i++)
	chrarr[i] = sprintf("%c", i)
    idxstr_cmp = arrlib::sprintf_idxs(chrarr, ":")
    valstr_cmp = arrlib::sprintf_vals(chrarr, ":")

    @dprint("* chrarr:") && arrlib::printa(chrarr)
    count = arrlib::get_idxs(chrarr, idxarr)
    @dprint("* idxarr:") && arrlib::printa(idxarr)
    idxstr = arrlib::sprintf_vals(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")
    testing::assert_equal(idxstr, idxstr_cmp, 1, "> idxstr == idxstr_cmp")

    count = arrlib::get_vals(chrarr, valarr)
    @dprint("* valarr:") && arrlib::printa(valarr)
    valstr = arrlib::sprintf_vals(valarr, ":")
    @dprint(sprintf("* valstr: <%s>", valstr))
    testing::assert_equal(count, arrlib::array_length(valarr), 1, "> (valarr) count == length")
    testing::assert_equal(valstr, valstr_cmp, 1, "> valstr == valstr_cmp")

    # change some values, empty string and unassigned
    @dprint("* change some chrarr values to the empty string and unassigned")
    chrarr[55] = ""
    delete chrarr[56]
    delete valarr
    delete idxarr
    idxstr_cmp = arrlib::sprintf_idxs(chrarr, ":")
    valstr_cmp = arrlib::sprintf_vals(chrarr, ":")
    count = arrlib::get_idxs(chrarr, idxarr)
    idxstr = arrlib::sprintf_vals(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")
    testing::assert_equal(idxstr, idxstr_cmp, 1, "> idxstr == idxstr_cmp")

    count = arrlib::get_vals(chrarr, valarr)
    valstr = arrlib::sprintf_vals(valarr, ":")
    @dprint(sprintf("* valstr: <%s>", valstr))
    testing::assert_equal(count, arrlib::array_length(valarr), 1, "> (valarr) count == length")
    testing::assert_equal(valstr, valstr_cmp, 1, "> valstr == valstr_cmp")

    delete a
    delete idxarr
    delete valarr
    a[0][1][11][111][1111][11111][111111] = "one"
    a[0][1][11][2][22][222][2222] = "two"
    a[0][1][11][3][33][333][3333] = "three"
    a[1][2][3][4][5][5][6] = "six"
    a[1][2][3][4][5][5][7] = "seven"
    a[1][2][4][5][6][7][8] = "eight"
    a[2][3][4][5][6][7][8][9] = "nine"
    @dprint("* a:") && arrlib::printa(a)

    idx_count = arrlib::get_idxs(a, idxarr)
    val_count = arrlib::get_vals(a, valarr)

    @dprint("* idxarr:") && arrlib::printa(idxarr)
    @dprint("* valarr:") && arrlib::printa(valarr)

    testing::assert_equal(idx_count, arrlib::array_length(idxarr), 1, "> idx_count == length(idxarr)")
    testing::assert_equal(idx_count, 36, 1, "> idx_count == 36")
    testing::assert_equal(val_count, arrlib::array_length(valarr), 1, "> val_count == length(valarr)")
    testing::assert_equal(val_count, 7, 1, "> val_count == 7")

    delete a
    delete idxarr
    delete valarr
    a[0]
    a[1][11]
    a[2][22][222]
    a[3][33][333][3333]
    a[4][44][444][4444][44444]
    a[5][55][555][5555][55555][555555]
    @dprint("* a:") && arrlib::printa(a)

    idx_count = arrlib::get_idxs(a, idxarr)
    val_count = arrlib::get_vals(a, valarr)

    @dprint("* idxarr:") && arrlib::printa(idxarr)
    @dprint("* valarr:") && arrlib::printa(valarr)

    testing::assert_equal(idx_count, arrlib::array_length(idxarr), 1, "> idx_count == length(idxarr)")
    testing::assert_equal(idx_count, 21, 1, "> idx_count == 21")
    testing::assert_equal(val_count, arrlib::array_length(valarr), 1, "> val_count == length(valarr)")
    testing::assert_equal(val_count, 6, 1, "> val_count == 6")
    
    # TEST uniq, uniq_idx
    awkpot::set_sort_order(_prev_order)
    _prev_order = awkpot::set_sort_order("@val_num_asc")
    delete __arr
    delete dest
    delete dest_i
    delete dest_v
    for (i=0;i<5;i++)
        if (i % 2) {
            for (ii=0;ii<5;ii++)
                __arr[i][ii]=(ii+1)*10
        } else {
	    __arr[i] = i
	}

    @dprint("* __arr:") && arrlib::printa(__arr)
    @dprint("* uniq...")
    arrlib::uniq(__arr, dest)
    @dprint("* dest (uniq):") && arrlib::printa(dest)
    @dprint("* uniq_idx...")
    arrlib::uniq_idx(__arr, dest_i)
    @dprint("* dest_i (uniq_idx):") && arrlib::printa(dest_i)
    testing::assert_equal(arrlib::sprintf_idxs(dest, ":"), "0:2:4:10:20:30:40:50", 1, "> uniq test dest (1)")
    testing::assert_equal(arrlib::sprintf_idxs(dest_i, ":"), "0:1:2:3:4", 1, "> uniq_idx test dest_i (1)")

    # check all values are unassigned:
    arrlib::uniq(dest, dest_v)
    testing::assert_equal(arrlib::array_length(dest_v), 1, 1, "> uniq dest_v length")
    for (i in dest_v) {
	t = awk::typeof(dest_v[i])
	# see NOTE_1
	if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	    testing::assert_equal(t, "unassigned", 1, "> uniq dest_v type")
	else
	    testing::assert_equal(t, "untyped", 1, "> uniq dest_v type")
    }
    delete dest_v
    arrlib::uniq(dest_i, dest_v)
    testing::assert_equal(arrlib::array_length(dest_v), 1, 1, "> uniq dest_v length (2)")
    for (i in dest_v)
	# see NOTE_1
	if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	    testing::assert_equal(typeof(dest_v[i]), "unassigned", 1, "> uniq dest_v type (2)")
	else
	    testing::assert_equal(typeof(dest_v[i]), "untyped", 1, "> uniq dest_v type (2)")


    delete __arr
    delete dest
    delete dest_i
    delete dest_v
    for (i=0;i<5;i++)
        __arr[i]=i%2    

    @dprint("* __arr:") && arrlib::printa(__arr)
    @dprint("* uniq...")
    arrlib::uniq(__arr, dest)
    @dprint("* dest (uniq):") && arrlib::printa(dest)
    @dprint("* uniq_idx...")
    arrlib::uniq_idx(__arr, dest_i)
    @dprint("* dest_i (uniq_idx):") && arrlib::printa(dest_i)
    testing::assert_equal(arrlib::sprintf_idxs(dest, ":"), "0:1", 1, "> uniq test dest (2)")
    testing::assert_equal(arrlib::sprintf_idxs(dest_i, ":"), "0:1:2:3:4", 1, "> uniq_idx test dest_i (2)")

    # check all values are unassigned:
    arrlib::uniq(dest, dest_v)
    testing::assert_equal(arrlib::array_length(dest_v), 1, 1, "> uniq dest_v length (3)")
    for (i in dest_v)
	# see NOTE_1
	if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	    testing::assert_equal(typeof(dest_v[i]), "unassigned", 1, "> uniq dest_v type (3)")
	else
	    testing::assert_equal(typeof(dest_v[i]), "untyped", 1, "> uniq dest_v type (3)")
    delete dest_v
    arrlib::uniq(dest_i, dest_v)
    testing::assert_equal(arrlib::array_length(dest_v), 1, 1, "> uniq dest_v length (4)")
    for (i in dest_v)
	# see NOTE_1
	if (awkpot::cmp_version(awkpot::get_version(), "5.2.2", "awkpot::le"))
	    testing::assert_equal(typeof(dest_v[i]), "unassigned", 1, "> uniq dest_v type (4)")
	else
	    testing::assert_equal(typeof(dest_v[i]), "untyped", 1, "> uniq dest_v type (4)")
    awkpot::set_sort_order(_prev_order)

    # TEST max_val / min_val / max_idx / min_idx
    @dprint("* test max_val / min_val")
    delete __arr
    top = 5
    for (i=0;i<=top;i++)
        __arr[i]=i
    testing::assert_equal(top, arrlib::max_val(__arr), 1, "> max_val")
    testing::assert_equal(0, arrlib::min_val(__arr), 1, "> min_val")
    testing::assert_equal(top, arrlib::max_idx(__arr), 1, "> max_idx")
    testing::assert_equal(0, arrlib::min_idx(__arr), 1, "> min_idx")

    # NOTE: indexes are stored as string, so comparison must be take this fact in consideration.
    __arr[-2] = 100
    __arr[9999] = -7 # choosed a value which is surely max as a string
    testing::assert_equal(__arr[-2], arrlib::max_val(__arr), 1, "> max_val (add max value)")
    testing::assert_equal(__arr[9999], arrlib::min_val(__arr), 1, "> min_val (add min value)")

    testing::assert_equal(9999, arrlib::max_idx(__arr), 1, "> max_idx (add max idx)")
    testing::assert_equal(-2, arrlib::min_idx(__arr), 1, "> min_idx (add min idx)")

    jtop = 44
    for (j=jtop; j >= 11; j/=2)
	for (i=top;i>=0;i--)
	    __arr[j][i] = j*i
    testing::assert_equal(top*jtop, arrlib::max_val(__arr), 1, "> max_val (nested)")

    # test with strings:
    delete a
    a[0]="z"
    a[1]="foobar"
    a[2]="bar"
    a[3]="12"
    a[4][1]="11"
    a[4][2]="foobar"
    a[4][3][1]="zoo"
    a[4][3][2]="1"
    a[4][4]="foo"
    testing::assert_equal("zoo", arrlib::max_val(a), 1, "> max_val (str, id)")
    testing::assert_equal("1", arrlib::min_val(a), 1, "> min_val (str, id)")

    testing::assert_equal("z", arrlib::max_val(a, "", 1), 1, "> max_val (str, id, depth=1)")
    testing::assert_equal("12", arrlib::min_val(a, "", 1), 1, "> min_val (str, id, depth=1)")

    testing::assert_equal("zoo", arrlib::max_val(a, "", 0, 1), 1, "> max_val (str, id, from=1)")
    testing::assert_equal("1", arrlib::min_val(a, "", 0, 1), 1, "> min_val (str, id, from=1)")

    testing::assert_equal("foobar", arrlib::max_val(a, "awkpot::len"), 1, "> max_val (str, len)")
    testing::assert_equal("z", arrlib::min_val(a, "awkpot::len"), 1, "> min_val (str, len)")

    # NOTE: quick tests, really no need to tests futhermore (min|max)_idx,
    #       since the inner mechanism is the same.
    delete a
    a["z"];a["foo"];a["ba"];a["xx"]["aa"];a["xx"]["bb"]
    testing::assert_equal("z", arrlib::max_idx(a), 1, "> max_idx (str, id)")
    testing::assert_equal("aa", arrlib::min_idx(a), 1, "> min_idx (str, id)")

    testing::assert_equal("z", arrlib::max_idx(a, "", 1), 1, "> max_idx (str, id, depth=1)")
    testing::assert_equal("ba", arrlib::min_idx(a, "", 1), 1, "> min_idx (str, id, depth=1)")

    testing::assert_equal("bb", arrlib::max_idx(a, "", 0, 1), 1, "> max_idx (str, id, from=1)")
    testing::assert_equal("aa", arrlib::min_idx(a, "", 0, 1), 1, "> min_idx (str, id, from=1)")

    testing::assert_equal("foo", arrlib::max_idx(a, "awkpot::len"), 1, "> max_idx (str, len)")
    testing::assert_equal("z", arrlib::min_idx(a, "awkpot::len"), 1, "> min_idx (str, len)")

    cmd = sprintf("%s -i arrlib 'BEGIN { arrlib::_cmp_elements(a,\"\",\"\",\"\",\"\",\"x\") }'", ARGV[0])
    testing::assert_false(awkpot::exec_command(cmd), 1, "> _cmp_elements: wrong 'what' arg")

    # TEST force_array
    delete a
    a[0] = 2
    a[2][0][1] = "foo"
    a[2][1] = "x"
    arrlib::force_array(a, 0)
    testing::assert_equal(typeof(a[0]), "array", 1, "> force_array(a, 0)")
    arrlib::force_array(a[2], 0)
    testing::assert_equal(typeof(a[2][0]), "array", 1, "> force_array(a[2], 0)")
    testing::assert_not_equal(a[2][0][1], "foo", 1, "> a[2][0][1] != \"foo\"")
    testing::assert_equal(a[2][1], "x", 1, "> a[2][1] == \"x\"")
    
    # TEST push / pop / popitem
    delete a
    delete b
    delete c
    split("1", a, ":")
    a[0] = 2
    a[2] = "baz"
    b[3][41]
    b[3][44] = "bar"
    b[3][55][66]
    b[4] = @/re/
    @dprint("* a:") && arrlib::printa(a)
    @dprint("* b:") && arrlib::printa(b)
    @dprint("* pops from a ...")
    while (arrlib::pop(a))
	@dprint("* a:") && arrlib::printa(b)
    testing::assert_true(arrlib::is_empty(a), 1, "> check is_empty(a) after popping")
    @dprint("* push foo at index foo ...")
    arrlib::push(a, "foo", "foo")
    testing::assert_equal(a["foo"], "foo", 1, "> a[\"foo\"] == \"foo\"")
    @dprint("* push bar at index foo ...")
    arrlib::push(a, "foo", "bar")
    testing::assert_equal(a["foo"], "bar", 1, "> a[\"foo\"] == \"bar\"")
    @dprint("* push array b at index 2 ...")
    arrlib::push(a, 2, b)
    @dprint("* a:") && arrlib::printa(a)
    testing::assert_equal(a[2][3][44], "bar", 1, "> a[2][3][44] = \"bar\"")
    testing::assert_true(arrlib::equals(a[2], b), 1, "> check a[2] eq b")

    delete aa
    arrlib::copy(a, aa)
    @dprint("* aa:") && arrlib::printa(aa)
    @dprint("* push scalar \"foo\" at index 2 ...")
    arrlib::push(aa, 2, "foo")
    testing::assert_equal(aa[2], "foo", 1, "> a[2] == \"foo\"")
    @dprint("* aa:") && arrlib::printa(aa)
    @dprint("* push array b at index \"foo\" ...")
    arrlib::push(aa, "foo", b)
    testing::assert_true(arrlib::equals(aa["foo"], b), 1, "> check a[\"foo\"] eq b")
    @dprint("* aa:") && arrlib::printa(aa)

    arrlib::popitem(a, "foo", c)
    testing::assert_equal(c["foo"], "bar", 1, "> c[foo] == bar")
    arrlib::popitem(a[2][3], 44, c)
    @dprint("* c:") && arrlib::printa(c)
    testing::assert_equal(c[44], "bar", 1, "> c[41] == bar")
    testing::assert_false(arrlib::popitem(c, "non-existent-index"), 1, "> popitem [non-existent-index]")
    testing::assert_true(arrlib::pop(c), 1, "> pop() from c")
    while (arrlib::pop(c)) {}
    testing::assert_false(arrlib::pop(c), 1, "> ! pop() from [empty] c")
    testing::assert_false(arrlib::popitem(c, "y"), 1, "> ! popitem() from [empty] c")
	
    

    testing::end_test_report()
    testing::report()
    exit(0)
}

# * runs:
# ~$ awk -v ARRLIB_DEBUG=1 -f arrlib_test.awk
# * list functions:
# awk '$0 ~ /^function [^_]/ {print gensub(/^(.*?)(\(.*)/, "\\1", "g", $2)}' ~/local/share/awk/arrlib.awk


