
@include "arrlib.awk"
@include "awkpot"
# https://github.com/crap0101/awkpot
@include "testing.awk"
# https://github.com/crap0101/laundry_basket/blob/master/testing.awk

@load "arrayfuncs"

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

    _stdout = "" # set false for array_print to print on stdout
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
	
    # TEST arrlib::array_copy && sorting order
    @dprint("* array_copy(arr, b)")
    arrlib::array_copy(arr, b)
    @dprint("* arr:") && arrlib::array_print(arr)
    @dprint("* b:") && arrlib::array_print(b)
    testing::assert_true(arrlib::equals(arr, b), 1, "> arrlib::equals(arr, b)")
    @dprint("* arrlib::array_copy(b, x)")
    arrlib::array_copy(b, x)
    @dprint("* x:") && arrlib::array_print(x)
    testing::assert_true(arrlib::equals(x, b), 1, "> arrlib::equals(x, b)")
    @dprint("* _prev_order = awkpot::set_sort_order(\"@ind_num_desc\")")
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* array_print(b)") && arrlib::array_print(b)
    @dprint("* arrlib::array_copy(b, b1)")
    arrlib::array_copy(b, b1)
    @dprint("* b1:") && arrlib::array_print(b1)
    @dprint("* awkpot::set_sort_order(_prev_order)")
    awkpot::set_sort_order(_prev_order)
    testing::assert_true(arrlib::equals(b1, b), 1, "> arrlib::equals(b1, b)")
    @dprint("* b1:") && arrlib::array_print(b1)
    @dprint(sprintf("* b1 (array_sprintf): <%s>", arrlib::array_sprintf(b1)))

    @dprint("* array_copy(bg, c, 3, 1)")
    arrlib::array_copy(bg, c, 3, 1)
    bgstr = arrlib::array_sprintf(bg, 3, 1)
    @dprint(sprintf("* array_sprintf(bg, 3, 1): <%s>", bgstr))
    cs = arrlib::array_sprintf(c)
    testing::assert_equal(cs, bgstr, 1, "> cs == bgstr")

    arrlib::array_copy(bg, d, 1)
    bgstr1 = arrlib::array_sprintf(bg, 1)
    ds = arrlib::array_sprintf(d)
    testing::assert_equal(ds, bgstr1, 1, "> ds == bgs1")
    
    arrlib::array_copy(bg, c)
    testing::assert_true(arrlib::equals(bg, c), 1, "> arrlib::equals(bg, c)")

    delete b1; delete c; delete d; delete x;
				   
    # TEST printing
    # array_sprintf, sort order, ...
    x["x"]="xx";x[0]=1;x[1]="zero";x[2]=3
    @dprint("* x:") && arrlib::array_print(x)
    @dprint("* array_print(x, _stdout, -1, -1, \"@ind_num_desc\"):") && arrlib::array_print(x, _stdout, -1, -1, "@ind_num_desc")
    arrlib::array_copy(b, b1)
    b1s = arrlib::array_sprintf(b1)
    testing::assert_equal(arrlib::array_sprintf(b), b1s, 1,
			  "> arrlib::array_sprintf(b) == arrlib::array_sprintf(b1)")

    @dprint("* _prev_order = set_sort_order(\"@ind_num_desc\")")
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* arrlib::array_print(ba):") && arrlib::array_print(ba)
    @dprint("* arrlib::array_copy(ba, bc)")
    arrlib::array_copy(ba, bc)
    @dprint("* arrlib::array_print(bc)") && arrlib::array_print(bc)
    bsa = arrlib::array_sprintf(ba)
    @dprint(sprintf("* bsa = arrlib::array_sprintf(ba): <%s>", bsa))
    bsc = arrlib::array_sprintf(bc)
    testing::assert_equal(bsa, bsc, 1, "> bsa == bsc")
    delete b1; delete bc
    
    # sprintf_val
    _t3 = awkpot::get_tempfile()
    arrlib::print_idx(ba, _t3)
    awkpot::read_file_arr(_t3, bf)
    array::deep_flat_array_idx(ba, bbg)
    asort(bbg)
    bs = arrlib::sprintf_val(bbg, ":")
    bs_over = arrlib::sprintf_val(bbg, ":", 1 + arrlib::array_deep_length(bbg))
    bs_neg = arrlib::sprintf_val(bbg, ":", 0)
    asort(bf)
    bfs = arrlib::sprintf_val(bf, ":")
    testing::assert_equal(bs, bfs, 1, "> bs == bfs")
    testing::assert_equal(bs_over, bfs, 1, "> bs_over == bfs")
    testing::assert_equal(bs, bs_neg, 1, "> bs == bs_neg")
    
    # check empty values
    _pv = awkpot::set_sort_order("@val_str_asc")
    va[0] = ""
    va[1] = 1
    va[2] = ""
    va[3] = 2
    va[4] = ""
    testing::assert_equal(arrlib::sprintf_val(va, ":"), ":::1:2", 1, "> sprintf_val (empty values) [@val_str_asc]")
    awkpot::set_sort_order("@ind_num_asc")
    testing::assert_equal(arrlib::sprintf_val(va, ":"), ":1::2:", 1, "> sprintf_val (empty values) [@ind_num_asc]")
    @dprint(sprintf("* vals <%s>\n", arrlib::sprintf_val(va, ":")))
    va[0]=0
    va[4]=4
    @dprint("* set va[0]=0; va[4]=4")
    testing::assert_equal(arrlib::sprintf_val(va, ":"), "0:1::2:4", 1, "> sprintf_val")
    @dprint("* set va[2]=\"due\"")
    va[2]="due"
    testing::assert_equal(arrlib::sprintf_val(va, ":"), "0:1:due:2:4", 1, "> sprintf_val")
    va[5][0]=""
    va[5][1]=11
    va[5][2]=""
    va[5][3]
    va[6][0]=""
    va[6][1]=""
    testing::assert_equal(arrlib::sprintf_val(va, ":"), "0:1:due:2:4::11::::", 1, "> sprintf_val (subarrays)")
    delete va

    # sprintf_idx
    va[0] = ""
    va[1] = 1
    va[2] = ""
    va[3] = 2
    va[4] = ""

    testing::assert_equal(arrlib::sprintf_idx(va, ":"), "0:1:2:3:4", 1, "> sprintf_idx")
    testing::assert_equal(arrlib::array_length(va), 5, 1, "(length) va == 5")
    va[""]="null"
    testing::assert_true(("" in va), 1, "> null in va?")
    testing::assert_equal(arrlib::sprintf_idx(va, ":"), ":0:1:2:3:4", 1, "> sprintf_idx (empty index)")
    testing::assert_equal(arrlib::array_length(va), 6, 1, "(length) va == 6")
    va[5][0]=""
    va[5][1]=11
    va[5][2]=""
    va[5][3]
    va[6][0]=""
    va[6][1]=""
    testing::assert_equal(arrlib::sprintf_idx(va, ":"), ":0:1:2:3:4:5:0:1:2:3:6:0:1", 1, "> sprintf_idx (subarrays)")
    delete va[""]

    awkpot::set_sort_order(_pv)
    delete va
    
    bs1 = arrlib::sprintf_idx(bbg, ":")
    bs2 = ""
    for (i=arrlib::array_length(bbg); i>1; i--)
	bs2 = bs2 i ":"
    bs2 = bs2 "" i
    testing::assert_equal(bs1, bs2, 1, "> bs == bs2")
    delete bd;delete be;delete bf;delete bbg

    # with depth
    _t1 = awkpot::get_tempfile()
    _t2 = awkpot::get_tempfile()
    @dprint(sprintf("* arrlib::array_print(ba, %s)", _t1))
    arrlib::array_print(ba, _t1, 2)
    bs = arrlib::array_sprintf(ba, 2)
    printf("%s",bs) >> _t2
    close(_t2)
    awkpot::read_file_arr(_t1, ba_read)
    awkpot::read_file_arr(_t2, bs_read)
    testing::assert_true(arrlib::equals(ba_read, bs_read), 1, "> ba_read == bs_read")
    
    # sprintf_val
    _t3 = awkpot::get_tempfile()
    arrlib::print_val(ba, _t3, 2)
    awkpot::read_file_arr(_t3, ba_read)
    @dprint("* ba_read:") && arrlib::array_print(ba_read)
    asort(ba_read)
    ba_str = arrlib::sprintf_val(ba_read, ":")
    arrlib::array_copy(ba, ba_pcopy, 2)
    @dprint("* ba_pcopy:") && arrlib::array_print(ba_pcopy)

    #arrlib::array_print
    array::deep_flat_array(ba_pcopy, ba_flat)
    @dprint("* ba_flat:") && arrlib::array_print(ba_flat)
    asort(ba_flat)
    ba_flat_str = arrlib::sprintf_val(ba_flat, ":")
    @dprint(sprintf("* ba_str: <%s>", ba_str))
    @dprint(sprintf("* ba_flat_str: <%s>", ba_flat_str))
    testing::assert_equal(ba_str, ba_flat_str, 1, "> ba_str == ba_flat_str")

    # sprintf_idx, sprintf_val (slices)
    @dprint("* bg:") && arrlib::array_print(bg)
    bgstr = arrlib::sprintf_idx(bg, ":", 2)
    @dprint(sprintf("* bgstr: <%s>", bgstr))
    split(bgstr, bgs, ":")
    asort(bgs)
    test_bgs = "A:0:1:2:B:C:D:1:2:C1:E"
    split(test_bgs, bgt, ":")
    asort(bgt)
    testing::assert_true(arrlib::equals(bgs, bgt), 1, "> sprintf_idx (depth=2): bgs == bgt")

    bgvstr = arrlib::sprintf_val(bg, ":", 2)
    split(bgvstr, bgvs, ":")
    asort(bgvs)
    test_bgv = "0:1::9:B1:B2"
    split(test_bgv, bgv, ":")
    asort(bgv)
    testing::assert_true(arrlib::equals(bgvs, bgv), 1, "> sprintf_val (depth=2): bgvs == bgv")

    delete bd;delete be;delete bf
    delete bgs; delete bgt; delete bgvs; delete bgv
    delete ba_read;delete ba_pcopy;delete ba_flat; delete ba_flat2

    bastr = arrlib::sprintf_idx(bg, ":", 3, 1)
    @dprint(sprintf("* bastr: <%s>", bastr))
    split(bastr, bas, ":")
    asort(bas)
    test_bas = "1:2:C1:E:0:2:3:F"
    split(test_bas, bat, ":")
    asort(bat)
    testing::assert_true(arrlib::equals(bas, bat), 1, "> sprintf_idx (depth=3, from=1): bas == bat")

    bavstr = arrlib::sprintf_val(bg, ":", 3, 1)
    split(bavstr, bavs, ":")
    asort(bavs)
    test_bav = "B1:B2:C1-0:C1-2:C1-3"
    split(test_bav, bav, ":")
    asort(bav)
    testing::assert_true(arrlib::equals(bavs, bav), 1, "> sprintf_val (depth=3, from =1): bavs == bav")
    delete bas; delete bat; delete bavs; delete bav

    _t1 = awkpot::get_tempfile()
    arrlib::print_idx(a, _t1)
    awkpot::read_file_arr(_t1, _c)
    awk::asort(_c)
    array::deep_flat_array_idx(a, _a)
    awk::asort(_a)
    @dprint(sprintf("* indexes from _a: <%s>", arrlib::sprintf_val(_a, ":")))
    @dprint(sprintf("* indexes from _c: <%s>", arrlib::sprintf_val(_c, ":")))
    testing::assert_equal(arrlib::sprintf_val(_a, ":"), arrlib::sprintf_val(_c, ":"),
			  1, "> (idx from _a) == (idx from _c)")

    _t1 = awkpot::get_tempfile()
    arrlib::print_val(a, _t1)
    awkpot::read_file_arr(_t1, _d)
    awk::asort(_d)
    array::deep_flat_array(a, _b)    
    awk::asort(_b)
    @dprint(sprintf("* indexes from _b: <%s>", arrlib::sprintf_val(_b, ":")))
    @dprint(sprintf("* indexes from _d: <%s>", arrlib::sprintf_val(_d, ":")))
    testing::assert_equal(arrlib::sprintf_val(_b, ":"), arrlib::sprintf_val(_d, ":"), 1,
			  "> (val from _b) == (val from _d)")
    @dprint("* set_sort_order(_prev_order)")
    awkpot::set_sort_order(_prev_order)
    
    # TEST arrlib::exists*
    arr["foo"]["bar"] = 12.2
    arr["foo"]["baz"] = "foo"
    @dprint("* arr:") && arrlib::array_print(arr)
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
    @dprint("* b:") && arrlib::array_print(b)
    testing::assert_equal(arrlib::array_length(b), 5, 1, "> array_length(b) == 5")
    @dprint("* array_copy(b, c)")
    arrlib::array_copy(b, c)
    @dprint("* c:") && arrlib::array_print(c)
    @dprint("* b:") && arrlib::array_print(b)
    testing::assert_true(arrlib::equals(b, c), 1, "> arrlib::equals(b, c)")
    for (i in b)
	testing::assert_equal(b[i], c[i], 1,
			      sprintf("> b[%s] == c[%s] --> (%s, %s)", i, i, b[i], c[i]))

    # TEST arrlib::*length
    @dprint("* delete b")
    delete b
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> test array_length(b) == 0")
    @dprint("* b:") && arrlib::array_print(b)
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
    @dprint("* a:") && arrlib::array_print(a)
    testing::assert_equal(arrlib::array_length(a), 3, 1, "> array_length(a) == 3 -->")
    testing::assert_equal(arrlib::array_deep_length(a), 9, "> array_deep_length(a) == 9")
    @dprint("* delete b")
    delete b
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> array_length(b) == 0")
    testing::assert_equal(arrlib::array_deep_length(b), 0, 1, "> array_deep_length(b) == 0")
    @dprint("* delete x")
    delete x
    @dprint("* set x[0]=0;x[1]=1;x[2]=2")
    x[0]=0;x[1]=1;x[2]=2
    testing::assert_equal(arrlib::array_length(x), 3, 1, "> array_length(x) == 3")
    testing::assert_equal(arrlib::array_deep_length(x), 3, 1, "> array_deep_length(x) == 3")
    @dprint("* delete x")
    delete x

    # TEST arrlib::equals
    @dprint("* delete c")
    delete c
    @dprint("* arrlib::array_copy(a, b)")
    arrlib::array_copy(a, b)
    @dprint("* array::copy_array(a, c)")
    array::copy_array(a, c)
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
    testing::assert_true(arrlib::array_sprintf(b) == arrlib::array_sprintf(b), 1, "> (sprintf) a == b)")
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
    
    # TEST test remove_empty && # TEST arrlib::array_copy with unassigned values
    arrlib::array_copy(ba, bb)
    testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    @dprint("* ba:") && arrlib::array_print(ba)
    @dprint("* bb:") && arrlib::array_print(bb)
    @dprint("* adding fake arrays to bb")
    bb["X-X-X"]
    bb["eggs"][0]
    bb["eggs"][1]
    bb["eggs"][2][1][2]
    bb["eggs"][2][1][2]
    @dprint("bb:") && arrlib::array_print(bb)

    ba_len = arrlib::array_deep_length(ba)
    bb_len = arrlib::array_deep_length(bb)
    testing::assert_not_equal(ba_len, bb_len, 1, "> (len) ba != (len) bb)")
    @dprint(sprintf("* (length) ba: %d, bb: %d", ba_len, bb_len))
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    
    @dprint("* arrlib::array_copy(bb, bc)")
    arrlib::array_copy(bb, bc)

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    bb_str = arrlib::array_sprintf(bb)
    bc_str = arrlib::array_sprintf(bc)
    @dprint(sprintf("* bb_str: <%s>", bb_str))
    @dprint(sprintf("* bc_str: <%s>", bc_str))
    testing::assert_equal(bb_str, bc_str, 1, "> (sprintf) bb == bc")
    awkpot::set_sort_order(_prev_order)

    #print "* bc:";arrlib::array_print(bc)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")

    @dprint("* remove_empty(bb)")
    arrlib::remove_empty(bb) # fake arrays not empty, so not removed
    @dprint("* bb:") && arrlib::array_print(bb)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    testing::assert_not_equal(ba_len, arrlib::array_deep_length(bb), 1, "> (len) ba != (len) bb)")
    @dprint(sprintf("* (length) ba: %d, bb: %d", arrlib::array_deep_length(ba), arrlib::array_deep_length(bb)))

    @dprint("* remove unassigned elements from bb")
    arrlib::remove_unassigned(bb) # now fake arrays are removed, unassigned elements too

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    @dprint("* ba:") && arrlib::array_print(ba)
    @dprint("* bb:") && arrlib::array_print(bb)
    testing::assert_false(arrlib::equals(bb, bc), 1, "> ! arrlib::equals(bc, bb)")
    @dprint("* arrlib::remove_unassigned(bc)")
    arrlib::remove_unassigned(bc) # remove fakes from bc too
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bc, bb)")

    testing::assert_equal(ba_len, arrlib::array_deep_length(bb), 1, "> (len) ba == (len) bb")
    @dprint(sprintf("* (length) ba: %d, bb: %d", arrlib::array_deep_length(ba), arrlib::array_deep_length(bb)))
    testing::assert_equal(arrlib::array_sprintf(bb), arrlib::array_sprintf(ba), 1, "> (sprintf) bb == ba")
    awkpot::set_sort_order(_prev_order)

    testing::assert_false(("eggs" in bb), 1, "> ! (\"eggs\" in bb)")
    testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    

    delete bd
    @dprint("* arrlib::array_copy(bb, bd)")
    arrlib::array_copy(bb, bd)
    @dprint("* bd:") && arrlib::array_print(bd)
    testing::assert_equal(arrlib::array_deep_length(bd), arrlib::array_deep_length(bb), 1, "> (len) bd == (len) bb)")
    testing::assert_true(arrlib::equals(bb, bd), 1, "> arrlib::equals(bd, bb)")
    
    # TEST get_idx / get_val
    delete idxarr
    @dprint("* test get_idx:")
    @dprint("* bg:") && arrlib::array_print(bg)
    count = arrlib::get_idx(bg, idxarr)

    @dprint("* idxarr:") && arrlib::array_print(idxarr)
    idxstr = arrlib::sprintf_val(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")

    count = arrlib::get_val(idxarr, valarr)
    @dprint("* valarr:") && arrlib::array_print(valarr)
    valstr = arrlib::sprintf_val(valarr, ":")
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
    idxstr_cmp = arrlib::sprintf_idx(chrarr, ":")
    valstr_cmp = arrlib::sprintf_val(chrarr, ":")

    @dprint("* chrarr:") && arrlib::array_print(chrarr)
    count = arrlib::get_idx(chrarr, idxarr)
    @dprint("* idxarr:") && arrlib::array_print(idxarr)
    idxstr = arrlib::sprintf_val(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")
    testing::assert_equal(idxstr, idxstr_cmp, 1, "> idxstr == idxstr_cmp")

    count = arrlib::get_val(chrarr, valarr)
    @dprint("* valarr:") && arrlib::array_print(valarr)
    valstr = arrlib::sprintf_val(valarr, ":")
    @dprint(sprintf("* valstr: <%s>", valstr))
    testing::assert_equal(count, arrlib::array_length(valarr), 1, "> (valarr) count == length")
    testing::assert_equal(valstr, valstr_cmp, 1, "> valstr == valstr_cmp")

    # change some values, empty string and unassigned
    @dprint("* change some chrarr values to the empty string and unassigned")
    chrarr[55] = ""
    delete chrarr[56]
    delete valarr
    delete idxarr
    idxstr_cmp = arrlib::sprintf_idx(chrarr, ":")
    valstr_cmp = arrlib::sprintf_val(chrarr, ":")
    count = arrlib::get_idx(chrarr, idxarr)
    idxstr = arrlib::sprintf_val(idxarr, ":")
    @dprint(sprintf("* idxstr: <%s>", idxstr))
    testing::assert_equal(count, arrlib::array_length(idxarr), 1, "> (idxarr) count == length")
    testing::assert_equal(idxstr, idxstr_cmp, 1, "> idxstr == idxstr_cmp")

    count = arrlib::get_val(chrarr, valarr)
    valstr = arrlib::sprintf_val(valarr, ":")
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
    @dprint("* a:") && arrlib::array_print(a)

    idx_count = arrlib::get_idx(a, idxarr)
    val_count = arrlib::get_val(a, valarr)

    @dprint("* idxarr:") && arrlib::array_print(idxarr)
    @dprint("* valarr:") && arrlib::array_print(valarr)

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
    @dprint("* a:") && arrlib::array_print(a)

    idx_count = arrlib::get_idx(a, idxarr)
    val_count = arrlib::get_val(a, valarr)

    @dprint("* idxarr:") && arrlib::array_print(idxarr)
    @dprint("* valarr:") && arrlib::array_print(valarr)

    testing::assert_equal(idx_count, arrlib::array_length(idxarr), 1, "> idx_count == length(idxarr)")
    testing::assert_equal(idx_count, 21, 1, "> idx_count == 21")
    testing::assert_equal(val_count, arrlib::array_length(valarr), 1, "> val_count == length(valarr)")
    testing::assert_equal(val_count, 6, 1, "> val_count == 6")

    
    awkpot::set_sort_order(_prev_order)

    
    testing::end_test_report()
    testing::report()

    if (NOHANGUP == 1) # exit after BEGIN. Use: awk -v NOHANGUP=1 -f thisfile
	exit(0)
}

# * runs:
# ~$ awk -v ARRLIB_DEBUG=1 -v NOHANGUP=1 -f arrlib_test.awk
# ~$ seq 30 | column | awk -f arrlib_test.awk
# * list functions:
# awk '$0 ~ /^function [^_]/ {print gensub(/^(.*?)(\(.*)/, "\\1", "g", $2)}' ~/local/share/awk/arrlib.awk

{
    arrlib::make_array_record(a)
    testing::assert_equal(arrlib::array_length(a), NF, 1, "arrlib::array_length(a) == NF")
    printf "* records: "
    for (i=1; i<=NF; i++)
	printf("%s ", a[i])
    printf "\n* delete a ...\n"
    delete a
    testing::assert_equal(arrlib::array_length(a), 0, 1, "arrlib::array_length(a) == 0")

}


