public class Converter {
	protected Converter() {}
	public static void main(String[] args) {
		String s = args[0];
		System.out.println("`default_nettype none");
		System.out.println();
		System.out.println("module message(");
		System.out.println("\tinput [8:0] pointer,");
		System.out.println("\toutput [8:0] value");
		System.out.println(");");
		System.out.println();
		System.out.println("reg [8:0] rom;");
		System.out.println("assign value = rom;");
		System.out.println("always @(*) begin");
		System.out.println("\tcase(pointer)");
		System.out.println("\t\tdefault: rom = 9'h1FF;");
		for(int i = 0; i < s.length(); i++) {
			int x = s.charAt(i) & 0xFF;
			if(Math.random() < 0.5) {
				x = 255 - x;
				x |= 256;
			}
			System.out.println("\t\t" + i + ": rom = " + x + ";");
		}
		System.out.println("\tendcase");
		System.out.println("end");
		System.out.println();
		System.out.println("endmodule");
	}
}
