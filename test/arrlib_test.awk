
@include "arrlib.awk"
@include "awkpot"
@include "testing.awk"

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
    print "* array_copy(arr, b)"
    arrlib::array_copy(arr, b)
    print "* arr:"; arrlib::array_print(arr)
    print "* b:"; arrlib::array_print(b)
    testing::assert_true(arrlib::equals(arr, b), 1, "> arrlib::equals(arr, b)")
    arrlib::array_copy(b, x)
    print "* arrlib::array_copy(b, x)"
    print "* x:"; arrlib::array_print(x)
    testing::assert_true(arrlib::equals(x, b), 1, "> arrlib::equals(x, b)")
    print "* _prev_order = awkpot::set_sort_order(\"@ind_num_desc\")"
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    print "* array_print(b) ..."; arrlib::array_print(b)
    print "* arrlib::array_copy(b, b1) ..."
    arrlib::array_copy(b, b1)
    print "* b1:"; arrlib::array_print(b1)
    print "* awkpot::set_sort_order(_prev_order)"
    awkpot::set_sort_order(_prev_order)
    testing::assert_true(arrlib::equals(b1, b), 1, "> arrlib::equals(b1, b)")
    print "* b1:"; arrlib::array_print(b1)
    print "* b1 (array_sprintf):"
    print arrlib::array_sprintf(b1)

    print "* array_copy(bg, c, 3, 1)"
    print "* array_sprintf(bg, 3, 1)"
    arrlib::array_copy(bg, c, 3, 1)
    bgstr = arrlib::array_sprintf(bg, 3, 1)
    cs = arrlib::array_sprintf(c)
    testing::assert_equal(cs, bgstr, 1, "> cs == bgstr")

    arrlib::array_copy(bg, d, 1)
    bgstr1 = arrlib::array_sprintf(bg, 1)
    ds = arrlib::array_sprintf(d)
    testing::assert_equal(ds, bgstr1, 1, "> ds == bgs1")

    arrlib::array_copy(bg, c)
    testing::assert_true(arrlib::equals(bg, c), 1, "> arrlib::equals(bg, c)")

    delete b1; delete c; delete d; delete x

    #################
    # TEST printing
    # array_sprintf, sort order, ...
    x["x"]="xx";x[0]=1;x[1]="zero";x[2]=3
    print "* x:"; arrlib::array_print(x)
    print "* array_print(x, _stdout, -1, -1, \"@ind_num_desc\"):"
    arrlib::array_print(x, _stdout, -1, -1, "@ind_num_desc")
    arrlib::array_copy(b, b1)
    b1s = arrlib::array_sprintf(b1)
    testing::assert_equal(arrlib::array_sprintf(b), b1s, 1,
			  "> arrlib::array_sprintf(b) == arrlib::array_sprintf(b1)")

    print "* _prev_order = set_sort_order(\"@ind_num_desc\")"
    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    print "* arrlib::array_print(ba):"; arrlib::array_print(ba)
    print "* arrlib::array_copy(ba, bc)"
    arrlib::array_copy(ba, bc)
    print "* arrlib::array_print(bc)"; arrlib::array_print(bc)
    print "* bs = arrlib::array_sprintf(ba):"
    bsa = arrlib::array_sprintf(ba)
    bsc = arrlib::array_sprintf(bc)
    testing::assert_equal(bsa, bsc, 1, "> bsa == bsc")
    delete b1; delete bc
    
    # sprintf_val
    _t3 = awkpot::get_tempfile()
    arrlib::print_idx(ba, _t3)
    awkpot::read_file(_t3, bf)
    deep_flat_array_idx(ba, bbg)
    asort(bbg)
    bs = arrlib::sprintf_val(bbg, ":")
    bs_over = arrlib::sprintf_val(bbg, ":", 1 + arrlib::array_deep_length(bbg))
    bs_neg = arrlib::sprintf_val(bbg, ":", 0)
    asort(bf)
    bfs = arrlib::sprintf_val(bf, ":")
    testing::assert_equal(bs, bfs, 1, "> bs == bfs")
    testing::assert_equal(bs_over, bfs, 1, "> bs_over == bfs")
    testing::assert_equal(bs, bs_neg, 1, "> bs == bs_neg")
    
    # sprintf_idx
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
    printf "* arrlib::array_print(ba, %s)\n", _t1
    arrlib::array_print(ba, _t1, 2)
    bs = arrlib::array_sprintf(ba, 2)
    printf("%s",bs) >> _t2
    close(_t2)
    awkpot::read_file(_t1, ba_read)
    awkpot::read_file(_t2, bs_read)
    testing::assert_true(arrlib::equals(ba_read, bs_read), 1, "ba_read == bs_read")
    
    # sprintf_val
    _t3 = awkpot::get_tempfile()
    arrlib::print_val(ba, _t3, 2)
    awkpot::read_file(_t3, ba_read)
    print "* ba_read:";arrlib::array_print(ba_read)
    asort(ba_read)
    ba_str = arrlib::sprintf_val(ba_read, ":")
    arrlib::array_copy(ba, ba_pcopy, 2)
    print "* ba_pcopy:";arrlib::array_print(ba_pcopy)

    #arrlib::array_print
    deep_flat_array(ba_pcopy, ba_flat)
    print "* ba_flat:";arrlib::array_print(ba_flat)
    asort(ba_flat)
    ba_flat_str = arrlib::sprintf_val(ba_flat, ":")
    print "* ba_str:", ba_str
    print "* ba_flat_str:", ba_flat_str
    testing::assert_equal(ba_str, ba_flat_str, 1, "> ba_str == ba_flat_str")

    # sprintf_idx, sprintf_val (slices)
    print "* bg:";arrlib::array_print(bg)
    bgstr = arrlib::sprintf_idx(bg, ":", 2)
    print "* bgstr:", bgstr
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
    print "* bastr:", bastr
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
    awkpot::read_file(_t1, _c)
    awk::asort(_c)
    deep_flat_array_idx(a, _a)
    awk::asort(_a)
    print "* indexes from _a:"
    print arrlib::sprintf_val(_a, ":")
    print "* indexes from _c:"
    print arrlib::sprintf_val(_c, ":")
    testing::assert_equal(arrlib::sprintf_val(_a, ":"), arrlib::sprintf_val(_c, ":"),
			  1, "> (idx from _a) == (idx from _c)")

    _t1 = awkpot::get_tempfile()
    arrlib::print_val(a, _t1)
    awkpot::read_file(_t1, _d)
    awk::asort(_d)
    deep_flat_array(a, _b)    
    awk::asort(_b)
    print "* indexes from _b:"
    print arrlib::sprintf_val(_b, ":")
    print "* indexes from _d:"
    print arrlib::sprintf_val(_d, ":")
    testing::assert_equal(arrlib::sprintf_val(_b, ":"), arrlib::sprintf_val(_d, ":"), 1,
			  "> (val from _b) == (val from _d)")
    print "* set_sort_order(_prev_order)"
    awkpot::set_sort_order(_prev_order)
    
    # TEST arrlib::exists*
    arr["foo"]["bar"] = 12.2
    arr["foo"]["baz"] = "foo"
    print "* arr:"; arrlib::array_print(arr)
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
    print "* delete arr ..."
    delete arr
    testing::assert_false(arrlib::exists_index_deep(arr, "bar"), 1, "> arrlib::exists_index_deep(arr, \"bar\")")
    print "-------"
    print "* set $1 = \"m\"; $2 = \"ll\"; $3 = \"?\"; $4 = 5; $5 = 99"

    # TEST arrlib::make_records && arrlib::exists_record
    $1 = "m"; $2 = "ll"; $3 = "?"; $4 = 5; $5 = 99
    testing::assert_false(arrlib::exists_record("?", 2), 1, "> ! exists_record(\"?\", 2)")
    testing::assert_true(arrlib::exists_record("?", 3), 1, "> exists_record(\"?\", 3)")
    testing::assert_true(arrlib::exists_record("?", 11), 1, "> exists_record(\"?\", 11)")
    testing::assert_false(arrlib::exists_record("not_existent", 11), 1, "> ! exists_record(\"not_existent\", 11)")
    testing::assert_true(arrlib::exists_record(5, 4), 1, "> exists_record(5, 4)")
    print "* make_array_record(b) ..."; arrlib::make_array_record(b)
    print "* b:"; arrlib::array_print(b)
    testing::assert_equal(arrlib::array_length(b), 5, 1, "> array_length(b) == 5")
    print "* array_copy(b, c)"; arrlib::array_copy(b, c)
    print "* c:"; arrlib::array_print(c)
    print "* b:"; arrlib::array_print(b)
    print "* test if b equals c:"
    testing::assert_true(arrlib::equals(b, c), 1, "> arrlib::equals(b, c)")
    for (i in b)
	testing::assert_equal(b[i], c[i], 1,
			      sprintf("> b[%s] == c[%s] --> (%s, %s)", i, i, b[i], c[i]))

    # TEST arrlib::*length
    print "* delete b ..."
    delete b
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> test array_length(b) == 0")
    print "* b:"; arrlib::array_print(b)
    print "* delete a ..."
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
    print "* a:"; arrlib::array_print(a)
    testing::assert_equal(arrlib::array_length(a), 3, 1, "> array_length(a) == 3 -->")
    testing::assert_equal(arrlib::array_deep_length(a), 9, "> array_deep_length(a) == 9")
    print "* delete b ..."
    delete b
    testing::assert_equal(arrlib::array_length(b), 0, 1, "> array_length(b) == 0")
    testing::assert_equal(arrlib::array_deep_length(b), 0, 1, "> array_deep_length(b) == 0")
    print "* delete x ..."
    delete x
    print "* set x[0]=0;x[1]=1;x[2]=2"; x[0]=0;x[1]=1;x[2]=2
    testing::assert_equal(arrlib::array_length(x), 3, 1, "> array_length(x) == 3")
    testing::assert_equal(arrlib::array_deep_length(x), 3, 1, "> array_deep_length(x) == 3")
    print "* delete x ..."
    delete x

    # TEST arrlib::equals
    print "* delete c ..."
    delete c
    print "* arrlib::array_copy(a, b)"
    arrlib::array_copy(a, b)
    print "* copy_array(a, c)"
    copy_array(a, c)
    testing::assert_true(arrlib::equals(b, c), 1, "> arrlib::equals(b, c)")
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    print "* set a[1] = 1"; a[1] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    testing::assert_false(arrlib::equals(a, c), 1, "> ! arrlib::equals(a, c)")
    print "* delete a[1]"
    delete a[1]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    testing::assert_true(arrlib::equals(a, c), 1, "> arrlib::equals(a, c)")

    print "* set a[\"spam\"][1] = 4; b[\"spam\"][5] = 5"
    a["spam"][1] = 4
    b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    print "* set a[\"spam\"][1] = \"spam1\""
    a["spam"][1] = "spam1"
    print "* delete  b[\"spam\"][5]"
    delete b["spam"][5]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")

    print "* set a[\"spam\"][4] = 4"
    a["spam"][4] = 4
    print "* set b[\"spam\"][5] = 5"
    b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")

    print "* delete a[\"spam\"][4]"
    delete a["spam"][4]
    print "* delete b[\"bar\"][5]"
    delete  b["spam"][5]
    testing::assert_true(arrlib::array_sprintf(b) == arrlib::array_sprintf(b), 1, "> (sprintf) a == b)")
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    
    print "* set b[1] = 1"; b[1] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    print "* delete b[1]"; delete b[1]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    print "* set b[\"spam\"][3] = \"spam2\""; b["spam"][3] = "spam2"
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    print "* set a[\"spam\"][3] = \"spam2\""; a["spam"][3] = "spam2"
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    print "* set b[\"spam\"][5] = 5"; b["spam"][5] = 5
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b) =")
    print "* delete b[\"spam\"][5] = 5"; delete b["spam"][5]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    print "* set a[\"bar\"][4][3] = 3"; a["bar"][4][3] = 3
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    print "* delete a[\"bar\"][4][3]"; delete a["bar"][4][3]
    testing::assert_true(arrlib::equals(a, b), 1, "> arrlib::equals(a, b)")
    print "* set b[\"bar\"][4][11] = 11"; b["bar"][4][11] = 1
    testing::assert_false(arrlib::equals(a, b), 1, "> ! arrlib::equals(a, b)")
    print "* delete b[\"bar\"][4][11]"; delete b["bar"][4][11]
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
    print "* delete b ..."
    delete b
    testing::assert_true(arrlib::is_empty(b), 1, "> arrlib::is_empty(b)")
    testing::assert_false(arrlib::array_length(b), 1, "> arrlib::array_length(b) == 0")
    print "* set b[0]=0;b[1]=1"; b[0]=0;b[1]=1
    testing::assert_false(arrlib::is_empty(b), 1, "> ! arrlib::is_empty(b)")
    print "* delete b[0]"; delete b[0]
    testing::assert_false(arrlib::is_empty(b), 1, "> ! arrlib::is_empty(b)")
    print "delete b[1]"; delete b[1]
    testing::assert_true(arrlib::is_empty(b), 1, "> arrlib::is_empty(b)")
    delete b
    
    # TEST test remove_empty && # TEST arrlib::array_copy with unassigned values
    arrlib::array_copy(ba, bb)
    testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    print "* ba:";arrlib::array_print(ba)
    print "* bb:";arrlib::array_print(bb)
    print "* adding fake arrays to bb..."
    bb["X-X-X"]
    bb["eggs"][0]
    bb["eggs"][1]
    bb["eggs"][2][1][2]
    bb["eggs"][2][1][2]
    print "bb:";arrlib::array_print(bb)

    ba_len = arrlib::array_deep_length(ba)
    bb_len = arrlib::array_deep_length(bb)
    testing::assert_not_equal(ba_len, bb_len, 1, "> (len) ba != (len) bb)")
    printf "* (length) ba: %d, bb: %d\n", ba_len, bb_len
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    
    print "* arrlib::array_copy(bb, bc)"
    arrlib::array_copy(bb, bc)

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    bb_str = arrlib::array_sprintf(bb)
    bc_str = arrlib::array_sprintf(bc)
    print "* bb_str";print bb_str
    print "* bc_str";print bc_str
    testing::assert_equal(bb_str, bc_str, 1, "> (sprintf) bb == bc")
    awkpot::set_sort_order(_prev_order)

    #print "* bc:";arrlib::array_print(bc)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")

    print "* remove_empty(bb)"
    arrlib::remove_empty(bb) # fake arrays not empty, so not removed
    print "* bb:"; arrlib::array_print(bb)
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bb, bc)")
    testing::assert_false(arrlib::equals(ba, bb), 1, "> ! arrlib::equals(ba, bb)")
    testing::assert_not_equal(ba_len, arrlib::array_deep_length(bb), 1, "> (len) ba != (len) bb)")
    printf "* (length) ba: %d, bb: %d\n", arrlib::array_deep_length(ba), arrlib::array_deep_length(bb)

    print "* remove unassigned elements from bb ..."
    arrlib::remove_unassigned(bb) # now fake arrays are removed, unassigned elements too

    _prev_order = awkpot::set_sort_order("@ind_num_desc")
    print "ba:";arrlib::array_print(ba)
    print "bb:";arrlib::array_print(bb)
    testing::assert_false(arrlib::equals(bb, bc), 1, "> ! arrlib::equals(bc, bb)")
    print "* arrlib::remove_unassigned(bc)"
    arrlib::remove_unassigned(bc) # remove fakes from bc too
    testing::assert_true(arrlib::equals(bb, bc), 1, "> arrlib::equals(bc, bb)")

    testing::assert_equal(ba_len, arrlib::array_deep_length(bb), 1, "> (len) ba == (len) bb")
    printf "* (length) ba: %d, bb: %d\n", arrlib::array_deep_length(ba), arrlib::array_deep_length(bb)
    testing::assert_equal(arrlib::array_sprintf(bb), arrlib::array_sprintf(ba), 1, "> (sprintf) bb == ba")
    awkpot::set_sort_order(_prev_order)

    testing::assert_false(("eggs" in bb), 1, "> ! (\"eggs\" in bb)")
    testing::assert_true(arrlib::equals(ba, bb), 1, "> arrlib::equals(ba, bb)")
    

    delete bd
    print "* arrlib::array_copy(bb, bd)"
    arrlib::array_copy(bb, bd)
    print "* bd:";arrlib::array_print(bd)
    testing::assert_equal(arrlib::array_deep_length(bd), arrlib::array_deep_length(bb), 1, "> (len) bd == (len) bb)")
    testing::assert_true(arrlib::equals(bb, bd), 1, "> arrlib::equals(bd, bb)")


    ### awk '$0 ~ /^function [^_]/ {print gensub(/^(.*?)(\(.*)/, "\\1", "g", $2)}' ~/local/share/awk/arrlib.awk
    testing::end_test_report()
    testing::report()

    if (NOHANGUP == 1) # exit after BEGIN. Use: awk -v NOHANGUP=1 -f thisfile
	exit(0)
}

# example: ~$ seq 30 | column | awk -f arrlib_test.awk
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


