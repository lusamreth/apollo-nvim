function! s:rust_execute_test()
	const FUNCTION_SEARCH_STATE = "function-search"
	const MOD_SEARCH_STATE = "mod-search"
	const FILE_SEARCH_STATE = "file-search"
	let test_path = []
	let state = FUNCTION_SEARCH_STATE
	let function_found = v:false
	let view = winsaveview()
	let lnum = view['lnum']
	let col = view['col']
	normal! [{
	while lnum != line(".") || col != col(".")
		if state == FUNCTION_SEARCH_STATE
			let function_name = <SID>is_test_function_block()
			if function_name != -1
				let test_path += [function_name]
				let function_found = v:true
				let state = MOD_SEARCH_STATE
			else
				let mod_name = <SID>is_mod_block()
				if mod_name != -1
					let test_path += [mod_name]
					let state = MOD_SEARCH_STATE
				endif
			endif
		elseif state == MOD_SEARCH_STATE
			let mod_name = <SID>is_mod_block()
			if mod_name != -1
				let test_path += [mod_name]
			endif
		endif
		let lnum = line(".")
		let col = col(".")
		normal! [{
	endwhile
	let cargo_arguments = "test --all-features"
	let file_path = []
	for segment in split(expand("%:p:r"), '/')
		" Before 'src', discard every segment of the path
		if segment == "src"
			let cargo_arguments .= " --lib"
			let state = FILE_SEARCH_STATE
		elseif segment == "tests"
			let cargo_arguments .= " --test " . expand("%:t:r")
			break
		elseif state == FILE_SEARCH_STATE
			" Every segment of the path is now a module (folder or files) at the 
			" exception of `lib.rs` and `main.rs`
			if segment != "lib" && segment != "main"
				let file_path += [segment]
			endif
		endif
	endfor
	let test_path = file_path + reverse(test_path)
	if function_found
		let cargo_arguments .= " -- --exact "
	else
		let cargo_arguments .= " -- "
	endif
	let cargo_arguments .= join(test_path, "::")
	call winrestview(view)
	" Run cargo command
	execute "cargo " . cargo_arguments
endfunction

" mapping f6 to this function!
noremap <F6> <Esc>:call <SID>rust_execute_test()<Enter>
