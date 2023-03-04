package org.test.test_env;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello ENV!" );
        System.getenv().entrySet().forEach(e -> 
        	System.out.println( e.getKey() + "=" + e.getValue()));
    }
}
