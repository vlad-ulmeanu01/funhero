var i, j;

if ( global.fun_sca == 1 )
{
    if ( global.scale == global.scale_lower )
        global.scale_dir = 1;
    else if ( global.scale == global.scale_upper )
        global.scale_dir = -1;
                
    global.scale += ( global.scale_amt * global.scale_dir );
    global.scale = max ( global.scale_lower, global.scale );
    global.scale = min ( global.scale_upper, global.scale );

    var alp = ( global.scale - global.scale_lower ) / ( global.scale_upper - global.scale_lower );
    alp = max ( 0.3, alp );
    
    for ( i = 1; i <= global.nr_col; i++ )
        with ( global.obj [ i, 1 ] )
        {
            image_xscale = global.scale;
            image_yscale = global.scale;  
            image_alpha = alp;
        }
    
    var rnd;
        
    for ( i = 1; i <= global.nr_col; i++ )
        for ( j = 2; j <= global.nr_lne; j++ )
            with ( global.obj [ i, j ] )
            {
                rnd = ( 1 + irandom ( 7 ) ) / 100;
                image_xscale = global.scale + rnd * global.scale_dir;
                image_yscale = global.scale + rnd * global.scale_dir;
                image_alpha = alp;          
            }     
}
