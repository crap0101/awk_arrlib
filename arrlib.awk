
# Pure awk functions to manage arrays


@include "awkpot"
# https://github.com/crap0101/awkpot

@namespace "arrlib"


#####################
# UTILITY FUNCTIONS #
#####################

function _check_equals(a, b) {
    # fake check
    printf("ERROR: function check_equals not set!\n") > "/dev/stderr"
    exit(1)
}

########################
# ACTUAL LIB FUNCTIONS #
########################

function _arr_print_rec(arr, outfile, depth, from,    fmt, _fmt, i) {
    # Private function to print the (possibly nested) array $arr
    # from the $from level until the $depth level of subarrays.
    # $depth shoud be a positive integer, if less than 1 scans
    # until the maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return
    for (i in arr) {
        if (awk::isarray(arr[i])) {
            _fmt = sprintf("%s[%s]", fmt, i)
            _arr_print_rec(arr[i], outfile, depth-1, from-1, _fmt)
        }
        else {
	    if (from <= 0)
		printf("arr%s[%s] = %s\n", fmt, i, arr[i]) >> outfile
	}
    }
}

function array_print(arr, outfile, depth, from, sort_type,    prev_sorted) {
    # Prints the (possibly nested) array $arr, optionally
    # starting from the $from level of subarrays until the $depth
    # level of subarrays and optionally
    # in sort_type order as per PROCINFO["sorted_in"].
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_arr_print_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    must_close = 1
    if (! outfile) {
	outfile = "/dev/stdout"
	must_close = 0
    }    
    if (sort_type)
	prev_sorted = awkpot::set_sort_order(sort_type)
    _arr_print_rec(arr, outfile, depth, from, "")
    if (sort_type) {
	awkpot::set_sort_order(prev_sorted)
	@dprint("revert to sort type:" PROCINFO["sorted_in"])
    }
    if (must_close)
	close(outfile)
}

function _arr_sprintf_rec(arr, depth, from,    fmt, _fmt, i, out) {
    # Private function to return a string representing the
    # (possibly nested) array $arr optionally starting at
    # the $from level of subarrays and (optionally) until the $depth
    # level of subarrays.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return ""
    out = ""
    for (i in arr) {
        if (awk::isarray(arr[i])) {
            _fmt = sprintf("%s[%s]", fmt, i)
            out = out _arr_sprintf_rec(arr[i], depth-1, from-1, _fmt)
        }
        else {
	    if (from <= 0)
		out = out sprintf("arr%s[%s] = %s\n", fmt, i, arr[i])
	}
    }
    return out
}

function array_sprintf(arr, depth, from, sort_type,    prev_sorted) {
    # Returns a string representing the (possibly nested)
    # array $arr, optionally in sort_type order as per PROCINFO["sorted_in"]
    # and optionally starting at the $from level of subarrays until the $depth
    # level of subarrays. If $from is less than 1, starts from the very level
    # of $arr. $depth should be a positive integer, if less than 1,
    # scans until the maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: (_arr_sprintf_rec) uses recursion.
    if (! from)
	from = 0
     if (! depth)
	depth = -1
    if (sort_type)
	prev_sorted = awkpot::set_sort_order(sort_type)
    out  =_arr_sprintf_rec(arr, depth, from, "")
    if (sort_type) {
	awkpot::set_sort_order(prev_sorted)
	@dprint("revert to sort type:" PROCINFO["sorted_in"])
    }
    return out
}

function _get_idx_rec(arr, dest, depth, from,    count, idx) {
    # Private function to get the indexes of the (possibly nested)
    # array $arr from the $from level until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # Indexes are stored in the $dest array as values.
    # $dest indexes starts from 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return count
    for (idx in arr) {
	_pre = depth pre "" idx
	if (from <= 0)
	    dest[count++] = idx
	if (awk::isarray(arr[idx]))
	    count = _get_idx_rec(arr[idx], dest, depth-1, from-1, count)
    }
    return count
}
function get_idx(arr, dest, depth, from,    count, idx) {
    # Function to get the indexes of the (possibly nested)
    # array $arr from the $from level until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # Indexes are stored in the $dest array as values.
    # $dest indexes starts from 0.
    # Returns the total number of indexes.
    # NOTE: uses recursion (_get_idx_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    count = 0
    return _get_idx_rec(arr, dest, depth, from, count)
}

function _print_idx_rec(arr, outfile, depth, from,    i, idx) {
    # Private function to print the indexes of the (possibly nested)
    # array $arr from the $from level until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # Write on $outfile.
    # NOTE: uses recursion.
    if (depth == 0)
	return
    for (idx in arr) {
	if (from <= 0)
	    print idx >> outfile
	if (awk::isarray(arr[idx]))
	    _print_idx_rec(arr[idx], outfile, depth-1, from-1)
    }
}

function print_idx(arr, outfile, depth, from,    i, idx) {
    # Prints a string of the indexes of the (possibly nested) array $arr,
    # optionally from the $from level of subarrays and optionally until
    # the $depth level of subarrays. If $from is less than 1, starts from
    # the very level of $arr. $depth should be a positive integer, if
    # less than 1 scans at the maximum depth.
    # The very level of $arr is at depth 0.
    # Write on $outfile (if false, default to stdout).
    # NOTE: uses recursion (_print_idx_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    must_close = 1
    if (! outfile) {
	outfile = "/dev/stdout"
	must_close = 0
    }
    _print_idx_rec(arr, outfile, depth, from)
    if (must_close)
	close(outfile)
}

function _sprintf_idx_rec(arr, separator, depth, from,    idx, out, s, empty_val) {
    # Private function to print on string the indeces of $arr
    # joined by $separator, optionally from the $from level
    # until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return ""
    out = ""
    empty_val = 0
    for (idx in arr) {
	if (awk::isarray(arr[idx])) {
	    if (from > 0) {
		if (out) {
		    s = _sprintf_idx_rec(arr[idx], separator, depth-1, from-1)
		    if (s)
			out = out separator s
		} else
		    out = _sprintf_idx_rec(arr[idx], separator, depth-1, from-1)
	    } else {
		if (out) {
		    s = _sprintf_idx_rec(arr[idx], separator, depth-1, from-1)
		    if (s)
			out = out separator idx separator s
		    else
			out = out separator idx
		} else {
		    s = _sprintf_idx_rec(arr[idx], separator, depth-1, from-1)
		    if (s)
			out = out idx separator s
		    else
			out = out idx
		}
	    }
	} else {
	    if (from <= 0) {
		if (! out) {
		    if (empty_val)
			out = out separator idx
		    else
			out = out idx
		    if (idx == "")
			empty_val = 1
		    else
			empty_val = 0
		} else
		    out = out separator idx
	    }
	}
    }
    return out
}
    
function sprintf_idx(arr, separator, depth, from) {
    # Returns a string of the indexes (separated by $separator)
    # of the (possibly nested) array $arr, optionally from the $from level
    # until the $depth level of subarrays. If $from is less than 1, starts
    # from the very level of $arr. $depth should be a positive integer. If
    # less than 1, scans until maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_sprintf_idx_rec).
    if (! separator)
	separator = ""
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    return _sprintf_idx_rec(arr, separator, depth, from)
}

function _get_val_rec(arr, dest, depth, from,    count, idx) {
    # Private function to get the values of the (possibly nested) array $arr,
    # from the $from level until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # Values are stored in the $dest array as values.
    # $dest indexes starts from 0.
    # Returns the total number of values.
    # NOTE: uses recursion.
    if (depth == 0)
	return count
    for (idx in arr)
	if (awk::isarray(arr[idx]))
	    count = _get_val_rec(arr[idx], dest, depth-1, from-1, count)
	else
	    if (from <= 0)
		dest[count++] = arr[idx]
    return count
}

function get_val(arr, dest, depth, from,    count, idx) {
    # Function to get the values of the (possibly nested) array $arr, optionally
    # from the $from level of subarrays and optionally until the $depth level
    # of subarrays. If $from is less than 1, scans from the very level of $arr.
    # $depth should be a positive integer, if less than 1 scans until max depth.
    # The very level of $arr is at depth 0.
    # Values are stored in the $dest array as values.
    # $dest indexes starts from 0.
    # Returns the total number of values.
    # NOTE: uses recursion (_get_val_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    count = 0
    return _get_val_rec(arr, dest, depth, from, count)
}

function _print_val_rec(arr, outfile, depth, from,    i, idx) {
    # Private function to print the values of the (possibly nested) array $arr,
    # from the $from level until the $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # Write on $outfile.
    # NOTE: uses recursion.
    if (depth == 0)
	return
    for (idx in arr)
	if (awk::isarray(arr[idx]))
	    _print_val_rec(arr[idx], outfile, depth-1, from-1)
	else
	    if (from <= 0)
		print arr[idx] >> outfile
}

function print_val(arr, outfile, depth, from,    i, idx) {
    # Prints the values of the (possibly nested) array $arr, optionally
    # from the $from level of subarrays and optionally until the $depth level
    # of subarrays. If $from is less than 1, scans from the very level of $arr.
    # $depth should be a positive integer, if less than 1 scans until max depth.
    # The very level of $arr is at depth 0.
    # Write on $outfile (if false, default to stdout).
    # NOTE: uses recursion (_print_val_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    must_close = 1
    if (! outfile) {
	outfile = "/dev/stdout"
	must_close = 0
    }
    _print_val_rec(arr, outfile, depth, from)
    if (must_close)
	close(outfile)
}

function _sprintf_val_rec(arr, separator, depth, from,    idx, out, empty_val) {
    # Private function to print on string the values of the
    # (possibly nested) array $arr, joined with $separator, optionally
    # from the $from level until the $depth level of subarrays.
    # $depth must be a positive integer, if less than 1 scans until max depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return ""
    out = ""
    empy_val = 0
    for (idx in arr) {
	if (awk::isarray(arr[idx])) {
	    if (out) {
		s = _sprintf_val_rec(arr[idx], separator, depth-1, from-1)
		if (s)
		    out = out separator s
	    } else
		out = _sprintf_val_rec(arr[idx], separator, depth-1, from-1)
	} else {
	    if (from <= 0) {
		if (! out) {
		    if (empty_val)
			out = out separator arr[idx]
		    else
			out = out arr[idx]
		    if (arr[idx] == "")
			empty_val = 1
		    else
			empty_val = 0
		} else
		    out = out separator arr[idx]
	    }
	}
    }
    return out
}

function sprintf_val(arr, separator, depth, from,    idx, out) {
    # Returns a string of the values of the (possibly nested) array $arr,
    # separated by $separator, optionally from the $from level
    # until the $depth level of subarrays. If $from is less than 1, scans from
    # the very level of $arr. $depth should be a positive integer,
    # if less than 1 scans until maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_sprintf_val_rec).
    if (! separator)
	separator = ""
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    return _sprintf_val_rec(arr, separator, depth, from)
}

function remove_empty(arr,    idx) {
    # Removes from $arr possibly created
    # empty arrays during copying or slicing.
    # NOTE: uses recursion.
    for (idx in arr)
	if (awk::isarray(arr[idx]))
	    if (is_empty(arr[idx]))
		delete arr[idx]
	    else
		remove_empty(arr[idx])
}

function remove_unassigned(arr,    idx, i, tmp) {
    # Removes unassigned and untyped values from $arr.
    # NOTE: uses recursion.
    for (idx in arr) {
	if (awk::isarray(arr[idx]))
	    remove_unassigned(arr[idx])
        # double check for gawk verion < 5.2
	if (awk::typeof(arr[idx]) == "unassigned" || awk::typeof(arr[idx]) == "untyped")
	    delete arr[idx]
    }
    # remove possibly empty arrays after removal of unassigned values
    for (idx in arr) {
	if (awk::isarray(arr[idx]))
	    if (is_empty(arr[idx]))
		delete arr[idx]
    }
}

function _array_copy_rec(source, dest, depth, from,    idx) {
    # Private function to make a copy of the
    # (possibly nested) $source array in the $dest array
    # from the $from level until the  $depth level of subarrays.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0) {
	return
    }
    for (idx in source) {
	if (awk::isarray(source[idx])) {
	    # To persuade dest[idx] to be an array.
	    # Come on boy! you can do it!
	    dest[idx]["fake"] = 1
	    delete dest[idx]["fake"]
	    _array_copy_rec(source[idx], dest[idx], depth-1, from-1)
	} else {
	    if (from <= 0)
		dest[idx] = source[idx]
	}
    }
    # to remove possibly created empty arrays ($depth reached)
    remove_empty(dest)

}

function array_copy(source, dest, depth, from) {
    # Make a copy of the $source array in the $dest array, optinally from
    # the $from level until the $depth level of subarrays. If $from is less
    # than 1, scans from the very level of $arr. $depth must be a positive
    # integer, if less than 1 scans until maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_array_copy_rec).
    if (! from)
	from = 0
    if (! depth)
	depth = -1
    _array_copy_rec(source, dest, depth, from)
}

function array_length(arr,    i, total) {
    # Returns the number of elements in $arr,
    # a supposedly flat array. Subarrays counts
    # as one element (use array_deep_length for
    # the total number of elements holds by $arr).
    total = 0
    for (i in arr)
	total += 1
    return total
}

function _array_deep_length(arr, depth,    i, total) {
    # Private function to return the number of elements in $arr,
    # optionally until $depth levels of subarrays.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion.
    if (depth == 0)
	return 0
    total = 0
    for (i in arr)
	if (awk::isarray(arr[i]))
	    total += _array_deep_length(arr[i], depth-1)
	else
	    total += 1
    return total
}

function array_deep_length(arr, depth) {
    # Returns the number of elements of the (possibly nested) array $arr,
    # optionally until $depth levels of subarrays. $depth must be a positive
    # integer, if less than 1 scans until maximum depth.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_array_deep_length).
    if (! depth)
	depth = -1
    return _array_deep_length(arr, depth)
}

function is_empty(arr,    idx, ret) {
    # Check if $arr is empty, i.e. deleted.
    # Returns 1 if empty, else 0.
    ret = 1
    for (idx in arr) {
	ret = 0
	break
    }
    return ret
}

function _exists_index_deep_rec(arr, index_value, level,    i) {
    # Private function to check if any index of $arr equals $index_value
    # Descends at most $level subarrays.
    # The very level of $arr is at depth 0.
    # Return 1 if true, else 0.
    # NOTE: uses recursion.
    if (level == 0)
	return 0
    if (index_value in arr)
	return 1
    else
	for (i in arr)
	    if (awk::isarray(arr[i]))
		if (_exists_index_deep_rec(arr[i], index_value, level - 1))
		    return 1
    return 0
}

function exists_index_deep(arr, index_value, level) {
    # Returns 1 if any index of $arr equals $index_value, else 0.
    # Optionally descends at most $level subarrays, if level < 1
    # or not provided, scans deep at most.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_exists_deep_index_rec).
    if (! level)
	level = -1
    return _exists_index_deep_rec(arr, index_value, level)
}

function exists_index(arr, index_value) {
    # Returns 1 if any index of $arr equals $index_value, else 0.
    # Like exists_index_deep, but without subarrays scanning.
    return exists_index_deep(arr, index_value, 1)
}

function _exists_deep_rec(arr, value, level,    i) {
    # Private function to check if any value element of $arr equals $value.
    # Descends at most $level subarrays.
    # The very level of $arr is at depth 0.
    # Returns 1 if true, else 0.
    # NOTE: uses recursion.
    if (level == 0)
	return 0
    for (i in arr)
	if (awk::isarray(arr[i])) {
	    if (_exists_deep_rec(arr[i], value, level - 1))
		return 1
	} else {
	    if (arr[i] == value)
		return 1
	}
    return 0
}

function exists_deep(arr, value, level) {
    # Returns 1 if any value element of $arr
    # (including subarrays) equals $value, else 0.
    # Optionally descends at most $level subarrays, if level < 1
    # or not provided, scans deep at most.
    # The very level of $arr is at depth 0.
    # NOTE: uses recursion (_exists_deep_rec).
    if (! level)
	level = -1
    return _exists_deep_rec(arr, value, level)

}

function exists(arr, value,    i) {
    # Returns 1 if any value element of $arr equals $value, else 0.
    # Like exists_deep, but without subarrays scanning.
    return exists_deep(arr, value, 1)
}

function exists_record(value, idx_max,    i) {
    # Checks if any field of the current record
    # (up to $idx_max) equals $value.
    # Returns the field number or 0 if not found.

    # Force idx_max to be a number
    idx_max += 0
    for (i = 1; i <= idx_max; i++) {
        if ($i == value)
            return i
    }
    return 0
}

function make_array_record(arr,    i) {
    # Puts the fields of the current record in arr.
    delete arr
    for (i = 1; i <= NF; i++) {
        arr[i] = $i
    }
}

function _equals_rec(arr1, arr2, level,    i) {
    # Private function to check if each value element of $arr1 equals
    # the corresponding element of $arr2 at the same index
    # Returns 1 if true, else 0.
    # Descends at most $level subarrays.
    # The very level of the arrays is at depth 0.
    # NOTE: uses recursion.
    if (level == 0)
	return 1
    if (array_length(arr1) != array_length(arr2))
	return 0
    # boilerplate code to avoid creating fake values:
    for (i in arr1)
    	if (! (i in arr2))
     	    return 0
    for (i in arr2)
     	if (! (i in arr1))
     	    return 0
    # ...end of boilerplate code (for now ^L^)    
    for (i in arr1) {
	if (awk::isarray(arr1[i])) {
	    if (! awk::isarray(arr2[i]))
		return 0
	    else
		if (! _equals_rec(arr1[i], arr2[i], level - 1))
		    return 0
	} else {
	    if (awk::isarray(arr2[i]))
		return 0
	    else
		if (! @check_equals(arr1[i], arr2[i]))
		    return 0
	}
    }
    return 1
}

function equals(arr1, arr2, level, check_type) {
    # Checks if each value element of $arr1 (including subarrays) equals
    # the value of the $arr2 element at the same index
    # Optionally descends at most $level subarrays, if level < 1
    # or not provided, scans deep at most. If $check_type is true,
    # comparison take into account the variable type also.
    # The very level of the arrays is at depth 0.
    # Returns 1 if true, else 0.
    # NOTE: uses recursion (_equals_rec).
    if (! level)
	level = -1
    if (! check_type)
	check_equals = "awkpot::equals"
    else
	check_equals = "awkpot::equals_typed"
    return _equals_rec(arr1, arr2, level)    
}


function _uniq(arr, dest,    idx) {  
    # Private (and partial) function for fill $dest array
    # with unique values from $arr array.
    # NOTE: used by the <uniq> function. If used alone,
    # needs a call to asorti($dest) to get the same result.
    # NOTE: uses recursion.
    for (idx in arr)
        if (awk::isarray(arr[idx]))
            _uniq(arr[idx], dest)
        else
            dest[arr[idx]]
}

function uniq(arr, dest) {
    # Fills $dest array with unique values from $arr array.
    # NOTE: uses recursion (_uniq).
    _uniq(arr, dest)
    awk::asorti(dest)
}

BEGIN {
    if (awk::ARRLIB_DEBUG_LEVEL) {
	dprint = "awkpot::dprint_real" #awkpot::set_dprint("awkpot::dprint_real")
	# to set dprint in awkpot functions also (defaults to dprint_fake)
	awkpot::set_dprint(dprint)
    } else {
	dprint = "awkpot::dprint_fake" #awkpot::set_dprint("awkpot::dprint_fake")
    }
    check_equals = "_check_equals"
}
