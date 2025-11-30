public class LUTGen {
	protected LUTGen() {}
	
	public static void main(String[] args) {
		for(int i = 0; i < 1024; i++) {
			double sine = Math.sin((double)i / 1024.0 * 0.5 * Math.PI);
			int sine_i = (int)(sine * 2048);
			System.out.println(i + ": quarter_sine = 12'd" + sine_i + ";");
		}
	}
}
