import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;

public class Convert {
	protected Convert() {}
	
	public static void main(String[] args) {
		BufferedImage img = null;
		try {
			img = ImageIO.read(new File(args[0]));
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		System.out.println("`default_nettype none");
		System.out.println();
		String s = args[0].toString();
		s = s.substring(0, s.indexOf("."));
		System.out.println("module " + s + "(");
		System.out.println("input [7:0] column,");
		System.out.println("input [6:0] row,");
		System.out.println("output [4:0] pixel");
		System.out.println(");");
		System.out.println();
		System.out.println("reg [4:0] rom;");
		System.out.println("assign pixel = rom;");
		System.out.println("always @(*) begin");
		System.out.println("\tcase({column, row})");
		System.out.println("\t\tdefault: rom = 5'hxx;");
		for(int i = 0; i < img.getWidth(); i++) {
			for(int j = 0; j < img.getHeight(); j++) {
				int index = j | (i << 7);
				int rgb = img.getRGB(i, j);
				//rgb >>= 16;
				rgb &= 0xFF;
				rgb >>= 3;
				System.out.println("\t\t" + index + ": rom = " + rgb + ";");
			}
		}
		System.out.println("\tendcase");
		System.out.println("end");
		System.out.println();
		System.out.println("endmodule");
	}
}
