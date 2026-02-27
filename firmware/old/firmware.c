//#define N 1024

#define GPIO_ADDR 0x10010000
#define MEM_ADDR  0x10040000
#define FFT_ADDR  0x10030000

int read_int(int addr)
{
    return *(volatile int*)addr;
}

void write_int(int addr,int c)
{
    *(volatile int*)addr = c;
}

int mul_fp(int a,int b)
{
    volatile int answ;
    write_int(0x10011000,a); //write in a
    write_int(0x10011004,b); //write in b
    answ = read_int(0x10011008);//read mul
    return answ;
}

int div_fp(int a,int b)
{
    volatile int answ;
    write_int(0x10011000,a); //write in a
    write_int(0x10011004,b); //write in b
    answ = read_int(0x1001100C);//read div
    return answ;
}

int exp_fp(int x) //taylor series
{
    int answ = 0; //1.0 for FP_32_16
    int term = 0x10000;
    int divisor = 0x10000;

    for(int i=1;i<8;i++)
    {   
        term = mul_fp(term,x);
        answ += div_fp(term,divisor);
        divisor = mul_fp(divisor,(i+1)*(int)0x10000);
    }

    return answ+0x10000;
}

int sqroot_fp(int square)
{
    int root=div_fp(square,0x30000);
    int i;
    if (square <= 0) return 0;
    for (i=0; i<20; i++)
    {
        int a = div_fp(square,root);
        int a1 = root + a;
        root = div_fp(a1, 0x20000);
    }

    return root;
}

int Bartlett_fp(int n, int offset,int W)
{
    volatile int window = 0;

    volatile int arg = div_fp(W,0x20000);    //W/2
    //write_int(0x10010000,arg);
    arg = n - offset - arg;         //n - offset - W/2
    //write_int(0x10010000,arg);
    if(arg < 0) arg = 0 - arg;       //abs == abs(n - offset - W/2)
    arg = mul_fp(arg,0x20000);      //2*abs
    //write_int(0x10010000,arg);
    arg = W - arg;                  // W-2abs
    if(arg < 0) return 0; 
    //write_int(0x10010000,arg);
    arg = div_fp(arg,W);            //(W-2abs)/W
    //write_int(0x10010000,arg);
              //if <0 return 0
    return arg;
}

//**************************************************************//

void main()
{
    volatile int sig = 0;
    volatile int a = 0;
    
    volatile int SIZE = 20000;
    
    volatile int output_value = 0;
    
    //volatile int b[10] = {1999,1999,1999,1999,1999,1999,1999,1999,1999,1999};
    
    //simple test
    /*
    for(int i = 0;i<32;i++)
    {
      sig = 1<<i;
      write_int(0x10010000,sig);
    }
    
    
    
    //test_exp
    sig = exp_fp(0x24CCC);
    write_int(0x10010000,sig);
    sig = exp_fp(0x32666);
    write_int(0x10010000,sig);

    //test_sqrt
    sig = sqroot_fp(0x20000);
    write_int(0x10010000,sig);
    sig = sqroot_fp(0x24CCC);
    write_int(0x10010000,sig);
    */
    
    /*
    sig = Bartlett_fp(0*0x10000,0x140000,0x140000);
    write_int(0x10010000,sig);
    sig = Bartlett_fp(25*0x10000,0x140000,0x140000);
    write_int(0x10010000,sig);
    sig = Bartlett_fp(30*0x10000,0x140000,0x140000);
    write_int(0x10010000,sig);
    */
    
    /*
    //test Bartlett window
    for(int i = 0; i < 512;i++)
    {
        a = i*0x10000;
        sig = Bartlett_fp(a,0x140000,0x140000);
        write_int(0x10010000,sig);
    }
    */
    
    volatile int N = 9;
    volatile int val = 0;
    
    for(int i = 0;i < SIZE;i++)
    {
        sig = read_int(MEM_ADDR + (i<<2));
        write_int(GPIO_ADDR,sig);   
    }
    
    
    for(int i = 0;i < SIZE;i++)
    {
        if(i<(N-1)) output_value = 0;
        else
        {
          output_value = 0;
          for(int k = 0; k < N; k++)
          {
            sig = read_int(MEM_ADDR + ((i-k)<<2));
            val = mul_fp(1999,sig);
            output_value+=val;    
          } 
        }
        write_int(GPIO_ADDR+4,output_value); 
        //write_int(GPIO_ADDR+4,3*sig);  //test sig printf 
        //write_int(FFT_ADDR + (i<<2),2*sig);
    }
    
    //print signal
    /*
    for(int i = 0;i < 1024;i++)
    {
        sig = read_int(MEM_ADDR + (i<<2));
        write_int(GPIO_ADDR,sig);             //test sig printf 
        //write_int(FFT_ADDR + (i<<2),2*sig);
    }
    */
    
    //work fft test
    /*
    volatile int sig_ar [N];
    
    //read signal and save in ar
    for(int i = 0;i < 1024;i++)
    {
        sig = read_int(MEM_ADDR + (i<<2));
        sig_ar[i] = sig;
    }
    
    
    for(int i = 0;i < 1024;i++)
    {
        sig = read_int(MEM_ADDR + (i<<2));
        write_int(GPIO_ADDR,sig);             //test sig printf 
        write_int(FFT_ADDR + (i<<2),2*sig);
    }
    
    write_int(FFT_ADDR+0x3004,1); //fft_control - run fft
    //write_int(0x10010000,2);
    

    //polling fft_end flag
    sig = read_int(FFT_ADDR+0x3008);
    while(sig==0)
    {
        sig = read_int(FFT_ADDR+0x3008);
        
        //write_int(0x10010000,3);
    }

    //write_int(0x10010000,4);
    write_int(FFT_ADDR+0x3004,0); //fft_control - stop fft

    for(int i = 0;i < 1024;i++)
    {
        sig = read_int((FFT_ADDR + 0x1000)+ (i<<2)); //read fft_real
        write_int(GPIO_ADDR,sig);
    }
    int mul_z;
        
        //mul sig on Bartlett_func
        for(int i = 0; i < N;i++)
        {
            a = i*0x10000; //convert int -> fp(32,16)
            sig = Bartlett_fp(a,0x140000,0x140000); //args: int n, int offset, int W
            mul_z = mul_fp(sig,sig_ar[i]); //mul: signal*window;
            write_int(FFT_ADDR + (i<<2),mul_z); //write in fft_buf
        }
        
        //run fft
        write_int(FFT_ADDR+0x3004,1); //fft_control - run fft
    

        //polling fft_end flag
        sig = read_int(FFT_ADDR+0x3008);
        while(sig==0) sig = read_int(FFT_ADDR+0x3008);
        
        //stop fft
        write_int(FFT_ADDR+0x3004,0); //fft_control - stop fft

        //read fft_r
        for(int i = 0;i < N;i++)
        {
            sig = read_int((FFT_ADDR + 0x1000)+ (i<<2)); //read fft_real
            write_int(GPIO_ADDR,sig); //hardware_printf
        }
        //read fft_i
        for(int i = 0;i < N;i++)
        {
            sig = read_int((FFT_ADDR + 0x2000)+ (i<<2)); //read fft_imag
            write_int(GPIO_ADDR,sig); //hardware_printf
        }
    //*/
    
    //full FFT
    /*
    volatile int sig_ar [N];
    
    //read signal and save in ar
    for(int i = 0;i < 1024;i++)
    {
        sig = read_int(MEM_ADDR + (i<<2));
        sig_ar[i] = sig;
    }
    
    ///*
    for(int k = 0; k < N;k++)
    {
        int offset = k*0x10000; //convert int -> fp(32,16)
        
        
        
    }
    
    */
    
    
    //*********************TEST_CODE*********************//
    /*
      for(int k = 0; k < N;k++)
      {
        int offset = k*0x10000; //convert int -> fp(32,16)
        int mul_z;
        
        //mul sig on Bartlett_func
        for(int i = 0; i < N;i++)
        {
            a = i*0x10000; //convert int -> fp(32,16)
            sig = Bartlett_fp(a,offset,0x140000); //args: int n, int offset, int W
            mul_z = mul_fp(sig,sig_ar[i]); //mul: signal*window;
            write_int(GPIO_ADDR,mul_z); //write in fft_buf
        }
      }
    
    */
    
}




/*
    // Initialize a character array with a coded message.

    char a = 0;

    for(int i = 0;i<64;i++)
    {
        a++;
        putc(a);
    }

    for(int i = 0;i<32;i++)
    {
        a = readc(0x10020000 + (i<<2));
        putc(a);
    }

    for(int i = 0;i <32;i++)write_int(0x10010000,1<<i);

    int b = 4;
    int c = 8;
    write_int(0x10010000,b+c);
    write_int(0x10010000,b-c);
    write_int(0x10010000,b*c);
    write_int(0x10010000,c/b);
    //*/
    //

    /*
    int sig;
    for(int i = 0;i <1024;i++)
    {
        sig = read_int(0x10030000 + (i<<2));
        write_int(0x10040000 + (i<<2),2*sig);
    }

    for(int i = 0;i <1024;i++)
    {
        sig = read_int(0x10030000 + (i<<2));
        write_int(0x10010000,2*sig);
    }
    for(int i = 0;i <1024;i++)
    {
        sig = read_int(0x10030000 + (i<<2));
        write_int(0x10010000,sig*32768);
    }
    */
