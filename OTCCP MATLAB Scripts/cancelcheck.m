function cancelcheck()
global canceled

    if canceled == 1
        ME = MExcpetion('MATLAB:Canceled', 'Analysis was canceled.');
        throw(ME)
    end
end